# ###############################################
# #     AWS EKS components
# ###############################################

data "aws_eks_cluster" "this" {
  count = var.create ? 1 : 0
  name  = var.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  count = var.create ? 1 : 0
  name  = var.cluster_name
  depends_on = [
    data.aws_eks_cluster.this
  ]
}

# ###############################################
# #     AWS base components
# ###############################################

data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["${var.vpc_prefix}*"]
  }
}

data "aws_subnets" "public_subnets" {
  count = "${lookup(var.argocd_alb_ingress_parameter, var.default_argocd_alb_ingress_parameter.argocd_alb_ingress_scheme, "internet-facing")}" == "internet-facing" ? 1 : 0
  filter {
    name   = "tag:Name"
    values = ["${var.vpc_public_subnets_name_prefix}*"]
  }
}

data "aws_route53_zone" "route53_zone" {
  name = var.custom_domain
}

# ###############################################
# #     External Secrets components
# ###############################################
data "aws_iam_openid_connect_provider" "this" {
  count = var.create ? 1 : 0
  url   = data.aws_eks_cluster.this[0].identity[0].oidc[0].issuer
}

data "aws_iam_policy_document" "eso_assume_role" {
  count = var.create && var.create_external_secrets ? 1 : 0
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type = "Federated"
      identifiers = [
        data.aws_iam_openid_connect_provider.this[0].arn
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_iam_openid_connect_provider.this[0].url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${lookup(var.helm_release_external_secrets_parameter, var.default_helm_repo_parameter.helm_repo_namespace, "external-secrets")}:${var.helm_release_external_secrets_serviceaccount_name}"]
    }
  }
}

# ###############################################
# #     Velero components
# ###############################################
data "aws_iam_policy_document" "velero_assume_role" {
  count = var.create && var.create_velero_controller ? 1 : 0
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type = "Federated"
      identifiers = [
        data.aws_iam_openid_connect_provider.this[0].arn
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_iam_openid_connect_provider.this[0].url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${lookup(var.helm_release_velero_parameter, var.default_helm_repo_parameter.helm_repo_namespace, "velero")}:${var.helm_release_velero_serviceaccount_name}"]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_iam_openid_connect_provider.this[0].url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

# ###############################################
# #     ArgoCD components
# ###############################################

data "kubernetes_ingress_v1" "aws_argocd_elb" {
  count = var.create && var.create_argocd ? 1 : 0
  metadata {
    name      = lookup(var.argocd_alb_ingress_parameter, var.default_argocd_alb_ingress_parameter.argocd_alb_ingress_name, "${var.cluster_name}-argocd-ingress-nginx")
    namespace = lookup(var.helm_release_argocd_ingress_nginx_parameter, var.default_helm_repo_parameter.helm_repo_namespace, "nginx")
  }
  depends_on = [
    kubernetes_ingress_v1.argocd_elb_ingress,
  ]
}

# # ###############################################
# # #     CAPA components
# # ###############################################
data "aws_iam_policy_document" "pod_identity_document" {
  statement {
    sid    = "AllowEksToAssumeRoleForPod"
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "pods.eks.amazonaws.com"
      ]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
    ]
  }
}
