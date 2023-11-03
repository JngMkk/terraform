data "aws_region" "current" {}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "sg_bastion" {
  name   = var.sg_bastion
  vpc_id = var.vpc_id

  ingress {
    from_port   = var.sg_bastion_ingress_rules["from_port"]
    to_port     = var.sg_bastion_ingress_rules["to_port"]
    protocol    = var.sg_bastion_ingress_rules["protocol"]
    cidr_blocks = var.sg_bastion_ingress_rules["cidr_blocks"]
  }

  egress {
    from_port   = var.sg_egress["from_port"]
    to_port     = var.sg_egress["to_port"]
    protocol    = var.sg_egress["protocol"]
    cidr_blocks = var.sg_egress["cidr_blocks"]
  }
}

resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.bastion_instance_type
  subnet_id              = var.public_sn_ids[0]
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.sg_bastion.id]
  user_data              = <<EOF
#!/bin/bash
su - ubuntu -c 'sudo apt update && sudo apt upgrade -y
sudo apt install awscli -y

mkdir /home/ubuntu/.aws
echo -e "[default]\naws_access_key_id=${var.access_key}\naws_secret_access_key=${var.secret_key}" > /home/ubuntu/.aws/credentials
echo -e "[default]\nregion=${data.aws_region.current.name}\noutput=json" > /home/ubuntu/.aws/config

curl -LO https://dl.k8s.io/release/v1.23.6/bin/linux/amd64/kubectl
chmod +x kubectl
mkdir -p /home/ubuntu/.local/bin
mv ./kubectl /home/ubuntu/.local/bin/kubectl

aws eks update-kubeconfig --region ${data.aws_region.current.name} --name ${aws_eks_cluster.eks_cluster.name}
sudo reboot
'

EOF

  tags = {
    Name = "${var.bastion}"
  }

  depends_on = [aws_eks_cluster.eks_cluster]
}
