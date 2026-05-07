output "cluster_name" {
  value       = module.EKS.cluster_name
}

output "rds_address" {
  description = "RDS address for configmap"
  value       = module.rds.rds_address
}

output "ecr_url" {
  value = module.ecr.ecr_repository_url
}
