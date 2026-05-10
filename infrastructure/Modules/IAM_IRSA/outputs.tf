output "external_secrets_role_arn" {
  description = "ARN of the IRSA role for External Secrets Operator"
  value       = aws_iam_role.external_secrets.arn
}

output "alb_controller_role_arn" {
  description = "ARN of the IRSA role for ALB Ingress Controller"
  value       = aws_iam_role.alb_controller.arn
}
