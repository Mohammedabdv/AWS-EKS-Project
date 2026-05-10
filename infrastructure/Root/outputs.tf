output "cluster_name" {
  value = module.EKS.cluster_name
}

output "rds_address" {
  description = "RDS address for configmap"
  value       = module.rds.rds_address
}

output "ecr_url" {
  value = module.ecr.ecr_repository_url
}

output "external_secrets_role_arn" {
  description = "حطه في GitHub Secret باسم EXTERNAL_SECRETS_ROLE_ARN"
  value       = module.IAM_IRSA.external_secrets_role_arn
}

output "alb_controller_role_arn" {
  description = "حطه في GitHub Secret باسم ALB_CONTROLLER_ROLE_ARN"
  value       = module.IAM_IRSA.alb_controller_role_arn
}
