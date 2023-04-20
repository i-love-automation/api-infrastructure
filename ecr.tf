resource "aws_ecr_repository" "api" {
  name                 = "api"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

  tags = local.tags
}

data "aws_ecr_image" "api_image" {
  repository_name = aws_ecr_repository.api.name
  most_recent     = true
}

output "api_image" {
  value = data.aws_ecr_image.api_image
}