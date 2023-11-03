resource "aws_ecr_repository" "ecrs" {
  count = length(var.aws_private_repos)

  name         = var.aws_private_repos[count.index]
  force_delete = true
}
