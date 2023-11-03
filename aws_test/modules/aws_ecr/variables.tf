variable "aws_private_repos" {
  type = list(string)
  default = [
    "backend",
    "frontend-landing"
  ]
}

variable "sg_web" {
  type    = string
  default = "web-sg"
}

variable "sg_web_ingress" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))

  default = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

variable "sg_egress" {
  type = object({
    from_port   = string
    to_port     = string
    protocol    = string
    cidr_blocks = list(string)
  })
}

variable "codebuild_resources" {
  type = list(map(string))
  default = [
    {
      name           = "backend-dev"
      image_name     = "backend"
      github_repo    = "backend"
      source_version = "develop"
      dockerfile     = "Dockerfile"
    },
    {
      name           = "backend-prod"
      image_name     = "backend"
      github_repo    = "backend"
      source_version = "main"
      dockerfile     = "Dockerfile"
    },
    {
      name           = "frontend-landing-dev"
      image_name     = "frontend-landing"
      github_repo    = "landing-web"
      source_version = "develop"
      dockerfile     = "Dockerfile.dev"
    },
    {
      name           = "frontend-landing-prod"
      image_name     = "frontend-landing"
      github_repo    = "landing-web"
      source_version = "master"
      dockerfile     = "Dockerfile.prod"
    }
  ]
}

variable "source_type" {
  type    = string
  default = "GITHUB"
}

variable "buildspec" {
  type    = string
  default = <<EOF
version: 0.2

phases:
  pre_build:
    commands:
      - aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $REGISTRY_HOST
    
  build:
    commands:
      - echo 'Start building.'
      - docker build -f $DOCKERFILE -t $IMAGE_NAME .
  
  post_build:
    commands:
      - docker tag $IMAGE_NAME $REGISTRY_HOST/$IMAGE_NAME:$IMAGE_TAG
      - docker push $REGISTRY_HOST/$IMAGE_NAME:$IMAGE_TAG
      - docker system prune -f
    finally:
      - echo 'Build completed.'
EOF
}

variable "github_prefix" {
  type    = string
  default = "https://github.com/private/"
}

variable "github_suffix" {
  type    = string
  default = ".git"
}

variable "git_clone_depth" {
  type    = number
  default = 1
}

variable "insecure_ssl" {
  type    = bool
  default = false
}

variable "report_build_status" {
  type    = bool
  default = false
}

variable "fetch_submodules" {
  type    = bool
  default = false
}

variable "env_type" {
  type    = string
  default = "LINUX_CONTAINER"
}

variable "env_compute_type" {
  type    = string
  default = "BUILD_GENERAL1_SMALL"
}

variable "image_pull_credentials_type" {
  type    = string
  default = "CODEBUILD"
}

variable "env_image" {
  type    = string
  default = "aws/codebuild/standard:4.0"
}

variable "privileged_mode" {
  type    = bool
  default = true
}

variable "env_variable_type" {
  type    = string
  default = "PLAINTEXT"
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "artifact_type" {
  type    = string
  default = "NO_ARTIFACTS"
}

variable "cache" {
  type    = string
  default = "NO_CACHE"
}

variable "cloudwatch_status" {
  type    = string
  default = "ENABLED"
}

variable "s3_status" {
  type    = string
  default = "DISABLED"
}

variable "badge_enabled" {
  type    = bool
  default = false
}

variable "timeout" {
  type    = number
  default = 20
}

variable "concurrent_build_limit" {
  type    = number
  default = 1
}
