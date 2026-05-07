variable "vpc_id" {
  type = string
}

variable "ALB_SG" {
  type    = string
  default = "alb-sg"
}

variable "EKS_SG" {
  type = string
  default = "eks_sg"
}

variable "RDS_SG" {
  type    = string
  default = "rds-sg"
}
