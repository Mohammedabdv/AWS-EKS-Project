output "EKS_SG_id" {
  value = aws_security_group.EKS_SG.id
}

output "RDS_SG_id" {
  value = aws_security_group.RDS_SG.id
}
