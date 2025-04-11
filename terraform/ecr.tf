resource "aws_ecr_repository" "iris_api" {
  name = "iris-api"
  image_scanning_configuration {
    scan_on_push = true
  }
  lifecycle {
    prevent_destroy = false
  }
}

output "ecr_repo_url" {
  value = aws_ecr_repository.iris_api.repository_url
}