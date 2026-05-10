# ─── IRSA: External Secrets Operator ──────────────────────────
resource "aws_iam_role" "external_secrets" {
  name = "eks-external-secrets-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = var.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${var.oidc_provider_url}:sub" = "system:serviceaccount:external-secrets:external-secrets-sa"
          "${var.oidc_provider_url}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "external_secrets_policy" {
  name = "external-secrets-secrets-manager"
  role = aws_iam_role.external_secrets.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
      Resource = "arn:aws:secretsmanager:*:*:secret:django-app/*"
    }]
  })
}

# ─── IRSA: ALB Ingress Controller ─────────────────────────────
resource "aws_iam_role" "alb_controller" {
  name = "eks-alb-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = var.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${var.oidc_provider_url}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          "${var.oidc_provider_url}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })
}

data "aws_iam_policy_document" "alb_controller" {
  statement {
    effect    = "Allow"
    actions   = ["iam:CreateServiceLinkedRole"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "iam:AWSServiceName"
      values   = ["elasticloadbalancing.amazonaws.com"]
    }
  }
  statement {
    effect  = "Allow"
    actions = [
      "ec2:DescribeAccountAttributes", "ec2:DescribeAddresses",
      "ec2:DescribeAvailabilityZones", "ec2:DescribeInternetGateways",
      "ec2:DescribeVpcs", "ec2:DescribeVpcPeeringConnections",
      "ec2:DescribeSubnets", "ec2:DescribeSecurityGroups",
      "ec2:DescribeInstances", "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeTags", "ec2:GetCoipPoolUsage",
      "ec2:DescribeCoipPools", "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeListenerCertificates",
      "elasticloadbalancing:DescribeSSLPolicies",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetGroupAttributes",
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticloadbalancing:DescribeTags",
      "elasticloadbalancing:DescribeTrustStores"
    ]
    resources = ["*"]
  }
  statement {
    effect  = "Allow"
    actions = [
      "cognito-idp:DescribeUserPoolClient", "acm:ListCertificates",
      "acm:DescribeCertificate", "iam:ListServerCertificates",
      "iam:GetServerCertificate", "waf-regional:GetWebACL",
      "waf-regional:GetWebACLForResource", "waf-regional:AssociateWebACL",
      "waf-regional:DisassociateWebACL", "wafv2:GetWebACL",
      "wafv2:GetWebACLForResource", "wafv2:AssociateWebACL",
      "wafv2:DisassociateWebACL", "shield:GetSubscriptionState",
      "shield:DescribeProtection", "shield:CreateProtection",
      "shield:DeleteProtection"
    ]
    resources = ["*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["ec2:AuthorizeSecurityGroupIngress", "ec2:RevokeSecurityGroupIngress"]
    resources = ["*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["ec2:CreateSecurityGroup"]
    resources = ["*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["ec2:CreateTags"]
    resources = ["arn:aws:ec2:*:*:security-group/*"]
    condition {
      test     = "StringEquals"
      variable = "ec2:CreateAction"
      values   = ["CreateSecurityGroup"]
    }
  }
  statement {
    effect    = "Allow"
    actions   = ["ec2:CreateTags", "ec2:DeleteTags"]
    resources = ["arn:aws:ec2:*:*:security-group/*"]
    condition {
      test     = "Null"
      variable = "aws:RequestedRegion"
      values   = ["false"]
    }
  }
  statement {
    effect    = "Allow"
    actions   = ["ec2:DeleteSecurityGroup"]
    resources = ["*"]
  }
  statement {
    effect  = "Allow"
    actions = [
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:CreateTargetGroup"
    ]
    resources = ["*"]
  }
  statement {
    effect  = "Allow"
    actions = [
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:CreateRule",
      "elasticloadbalancing:DeleteRule"
    ]
    resources = ["*"]
  }
  statement {
    effect  = "Allow"
    actions = [
      "elasticloadbalancing:AddTags", "elasticloadbalancing:RemoveTags"
    ]
    resources = [
      "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
      "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
      "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
    ]
  }
  statement {
    effect  = "Allow"
    actions = [
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:SetIpAddressType",
      "elasticloadbalancing:SetSecurityGroups",
      "elasticloadbalancing:SetSubnets",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:ModifyTargetGroupAttributes",
      "elasticloadbalancing:DeleteTargetGroup"
    ]
    resources = ["*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["elasticloadbalancing:RegisterTargets", "elasticloadbalancing:DeregisterTargets"]
    resources = ["arn:aws:elasticloadbalancing:*:*:targetgroup/*/*"]
  }
  statement {
    effect  = "Allow"
    actions = [
      "elasticloadbalancing:SetWebAcl",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:AddListenerCertificates",
      "elasticloadbalancing:RemoveListenerCertificates",
      "elasticloadbalancing:ModifyRule"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "alb_controller" {
  name   = "AWSLoadBalancerControllerIAMPolicy"
  policy = data.aws_iam_policy_document.alb_controller.json
}

resource "aws_iam_role_policy_attachment" "alb_controller" {
  policy_arn = aws_iam_policy.alb_controller.arn
  role       = aws_iam_role.alb_controller.name
}
