terraform {
  required_version = "~> 1.5.0" # 테라폼 버전

  #   required_providers {
  #     random = {
  #         version = ">= 3.0.0, < 3.1.0"       # 프로바이더 버전을 나열
  #     }

  #     aws = {
  #         source = "hashicorp/aws"
  #         version = "~> 4.2.0"
  #     }

  #     azurerm = {
  #         source = "hashicorp/azurerm"
  #         version = ">= 2.99.0"
  #     }
  #   }

  backend "local" { # state를 보관하는 위치를 지정
    path = "state/terraform.tfstate"
  }
}

resource "local_file" "hello_world" { # local 프로바이더에 속한 리소스 유형(file)
  content  = "Hello World!"
  filename = "${path.module}/hello_world.txt"
}

resource "local_file" "bye_world" {
  #   depends_on = [                            # local_file.hello_world에 대한 종속성 명시
  #     local_file.hello_world 
  #   ]

  content  = local_file.hello_world.content
  filename = "${path.module}/bye_world.txt"
}
