terraform {
  required_version = "~> 1.9.0"

  required_providers {
    ncloud = {
      source  = "NaverCloudPlatform/ncloud"
      version = "3.1.1"
    }
  }
}


###############################################################################
#                                     ACG                                     #
###############################################################################
resource "ncloud_access_control_group" "bastion_acg" {
  name = var.bastion_acg_name

  vpc_no = var.vpc_id
}

resource "ncloud_access_control_group_rule" "acg_rule" {
  access_control_group_no = ncloud_access_control_group.bastion_acg.id

  inbound {
    protocol    = "TCP"
    ip_block    = var.office_ip_block
    port_range  = "22"
    description = "ssh from office ip"
  }

  outbound {
    protocol   = "TCP"
    ip_block   = "0.0.0.0/0"
    port_range = "1-65535"
  }
}


###############################################################################
#                                   SERVER                                    #
###############################################################################
resource "ncloud_init_script" "init_script" {
  name    = "init-script"
  content = <<-EOF
      #!/bin/bash
      apt-get update && apt-get upgrade -y
      apt-get install -y apt-transport-https ca-certificates curl software-properties-common
        
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
      add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
      apt-get update
      apt-get install -y docker-ce docker-ce-cli containerd.io

      systemctl start docker
      systemctl enable docker
    EOF
}

resource "ncloud_server" "servers" {
  count = length(var.servers)

  name                      = var.servers[count.index].name
  subnet_no                 = var.private_subnet_id
  server_image_product_code = var.servers[count.index].server_product_code

  init_script_no = var.servers[count.index].use_init_script ? ncloud_init_script.init_script.id : null

  tag_list {
    tag_key   = "env"
    tag_value = var.servers[count.index].env_tag
  }
}

data "ncloud_server" "bastion_server" {
  filter {
    name   = "name"
    values = [var.bastion_server_name]
  }
}

resource "ncloud_public_ip" "bastion_server_ip" {
  server_instance_no = data.ncloud_server.bastion_server.instance_no
}
