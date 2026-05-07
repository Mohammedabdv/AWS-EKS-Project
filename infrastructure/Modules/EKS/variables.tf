variable "cluster_role_arn" {
  type = string
}

variable "node_role_arn" {
  type = string
}

variable "eks_cluster_name" {
  type    = string
  default = "app_cluster"
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "eks_sg_id" {
  type = string
}
