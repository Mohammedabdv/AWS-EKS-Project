variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "internet_gateway_name" {
  type    = string
  default = "Custome_VPC_IGW"
}

variable "public_subnet_cidr" {
  type    = list(string)
  default = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "availability_zone" {
  type = list(string)
}

variable "private_subnet_cidr" {
  type    = list(string)
  default = ["10.0.100.0/24", "10.0.200.0/24"]
}

