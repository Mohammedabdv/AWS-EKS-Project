resource "aws_eks_cluster" "main" {
  name = var.eks_cluster_name

  access_config {
    authentication_mode = "API"
  }

  role_arn = var.cluster_role_arn
  version  = "1.31"

  bootstrap_self_managed_addons = false

  compute_config {
    enabled       = true
    node_pools    = ["general-purpose"]
    node_role_arn = var.node_role_arn
  }

  kubernetes_network_config {
    elastic_load_balancing {
      enabled = true
    }
  }

  storage_config {
    block_storage {
      enabled = true
    }
  }

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
    subnet_ids = concat(
      var.private_subnet_ids,
      var.public_subnet_ids
    )
    security_group_ids = [var.eks_sg_id]
  }
}

# ← مضاف: OIDC Provider — مطلوب لـ IRSA (External Secrets + ALB Controller)
data "tls_certificate" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer
}
