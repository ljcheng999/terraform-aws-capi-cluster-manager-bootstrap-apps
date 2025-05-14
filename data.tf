data "aws_eks_cluster" "this" {
  count = local.create ? 1 : 0
  name  = var.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  count = local.create ? 1 : 0
  name  = var.cluster_name
  depends_on = [
    data.aws_eks_cluster.this
  ]
}

data "aws_iam_openid_connect_provider" "this" {
  count = local.create ? 1 : 0
  url   = data.aws_eks_cluster.this[0].identity[0].oidc[0].issuer
}


data "aws_iam_policy_document" "eso_assume_role" {
  count = local.create && local.create_external_secrets ? 1 : 0
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
      values   = ["system:serviceaccount:${lookup(local.helm_release_external_secrets_parameter, var.default_helm_repo_parameter.helm_repo_namespace, "external-secrets")}:${var.helm_release_external_secrets_serviceaccount_name}"]
    }
  }
}
data "aws_iam_policy_document" "velero_assume_role" {
  count = local.create && local.create_velero_controller ? 1 : 0
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
      values   = ["system:serviceaccount:${lookup(local.helm_release_velero_parameter, var.default_helm_repo_parameter.helm_repo_namespace, "velero")}:${var.helm_release_velero_serviceaccount_name}"]
    }
  }
}




# data "aws_route_table" "example" {
#   vpc_id = "vpc-123456" # Replace with your VPC ID
#   tags = {
#     Name = "routetable-name"
#   }
# }

data "aws_subnets" "public_subnets" {
  count = "${lookup(local.helm_release_argocd_controller_parameter, var.default_argocd_alb_ingress_parameter.aws_argocd_alb_ingress_scheme, "internet-facing")}" == "internet-facing" ? 1 : 0
  filter {
    name   = "tag:Name"
    values = ["${var.vpc_public_subnets_name_prefix}*"]
  }
}



# output "public_aws_subnets" {
#   value = data.aws_subnets.public_subnets
# }

# # This data will contain all subnets associated with the given route table
# data "aws_subnet" "associated" {
#   for_each = toset([for assoc in data.aws_route_table.example.associations : assoc.subnet_id])

#   id = each.key
# }

# # Use the setsubtract function to find unassociated subnets
# locals {
#   all_subnet_ids = [for subnet in data.aws_subnets.all.ids : subnet]
#   associated_subnet_ids = [for subnet in data.aws_route_table.example.associations : subnet.subnet_id]
#   unassociated_subnet_ids = setsubtract(local.all_subnet_ids, local.associated_subnet_ids)
# }








# # Find a certificate issued by (not imported into) ACM
# data "aws_acm_certificate" "argo_cd_amazon_issued" {
#   count       = var.create_argocd_cert ? 1 : 0
#   domain      = local.final_acm_domain
#   types       = ["AMAZON_ISSUED"]
#   most_recent = true

#   depends_on = [ 
#     aws_acm_certificate_validation.argo.0
#   ]
# }

# data "aws_acm_certificate" "kube_dashboard_amazon_issued" {
#   count       = var.create_kube_dashboard_cert ? 1 : 0
#   domain      = local.final_kube_dashboard_acm_domain
#   types       = ["AMAZON_ISSUED"]
#   most_recent = true

#   depends_on = [ 
#     aws_acm_certificate_validation.kube_dashboard.0
#   ]
# }
