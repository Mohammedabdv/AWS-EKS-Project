provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host                   = module.EKS.cluster_endpoint
  cluster_ca_certificate = base64decode(module.EKS.cluster_certificate_authority)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.EKS.cluster_name]
  }
}

module "networking" {
  source            = "../Modules/Networking"
  availability_zone = var.availability_zone
}

module "security" {
  source = "../Modules/Security"
  vpc_id = module.networking.vpc_id
}

module "ecr" {
  source = "../Modules/ECR"
}

module "rds" {
  source             = "../Modules/RDS"
  private_subnet_ids = module.networking.private_subnet_ids
  RDS_SG_id          = module.security.RDS_SG_id
  db_username        = var.db_username
  db_password        = var.db_password
}

module "Secrets_Manager" {
  source      = "../Modules/Secrets_Manager"
  secret_key  = var.secret_key
  db_username = var.db_username
  db_password = var.db_password
}

# الترتيب الصحيح بدون cycles:
# IAM_Policy ──► EKS ──► IAM_IRSA
#   (cluster/node roles)    (OIDC)    (IRSA roles)

module "IAM_Policy" {
  source = "../Modules/IAM_Policy"
  # لا يعتمد على أي موديول آخر → لا توجد دورة
}

module "EKS" {
  source             = "../Modules/EKS"
  cluster_role_arn   = module.IAM_Policy.cluster_role_arn
  node_role_arn      = module.IAM_Policy.node_role_arn
  private_subnet_ids = module.networking.private_subnet_ids
  public_subnet_ids  = module.networking.public_subnet_ids
  eks_sg_id          = module.security.EKS_SG_id

  depends_on = [module.IAM_Policy]
}

module "IAM_IRSA" {
  source = "../Modules/IAM_IRSA"

  # يعتمد على EKS فقط → لا توجد دورة
  oidc_provider_arn = module.EKS.oidc_provider_arn
  oidc_provider_url = module.EKS.oidc_provider_url

  depends_on = [module.EKS]
}
