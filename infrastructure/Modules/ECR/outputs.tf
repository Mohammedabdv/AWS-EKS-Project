output "ecr_repository_url" {
  description = "The URL of the ECR repository, which can be used to push and pull Docker images."
  value       = aws_ecr_repository.app_repo.repository_url
}
