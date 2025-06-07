resource "kubernetes_service_account" "capa_cluster_service_account" {
  count = var.create && var.create_argocd ? 1 : 0

  metadata {
    name      = "capa-sa"
    namespace = lookup(var.helm_release_argocd_parameter, var.default_helm_repo_parameter.helm_repo_namespace, "argocd")
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.capi_service_account[0].arn
    }
  }

  depends_on = [
    helm_release.argocd,
  ]
}

resource "aws_iam_role" "capi_service_account" {
  count              = var.create && var.create_argocd ? 1 : 0
  name               = "${var.cluster_name}-cluster-service-account"
  assume_role_policy = data.aws_iam_policy_document.capi_service_account[0].json
}

resource "aws_iam_role_policy_attachment" "capi_service_account_policy_attachment" {
  count = var.create && var.create_argocd ? 1 : 0

  role       = aws_iam_role.capi_service_account[0].name
  policy_arn = aws_iam_policy.capi_service_account_policy.arn
}

resource "aws_iam_policy" "capi_service_account_policy" {
  name        = "${var.cluster_name}-cluster-service-account-policy"
  description = "${var.cluster_name}-cluster-service-account-policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:ModifyVpcAttribute",
          "ec2:DescribeVpcAttribute",
          "ec2:DescribeNatGateways",
          "ec2:DescribeAvailabilityZones",
          "ec2:CreateVpc",
          "ec2:CreateSubnet",
          "ec2:CreateRouteTable",
          "ec2:CreateRoute",
          "ec2:CreateInternetGateway",
          "ec2:AttachInternetGateway",
          "ec2:AssociateVpcCidrBlock",
          "ec2:AssociateRouteTable",
          "ec2:CreateTags",
        ]
        Effect   = "Allow"
        Resource = "*"
        "Sid" : "CapaSaEc2"
      },
      {
        Action = [
          "iam:TagRole",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:PassRole",
          "iam:ListAttachedRolePolicies",
          "iam:GetRole",
          "iam:GetPolicy",
          "iam:DetachRolePolicy",
          "iam:DeleteRole",
          "iam:DeleteInstanceProfile",
          "iam:CreateRole",
          "iam:CreatePolicy",
          "iam:CreateInstanceProfile",
          "iam:AttachRolePolicy",
          "iam:AddRoleToInstanceProfile"
        ]
        Effect   = "Allow"
        Resource = "*"
        "Sid" : "CapaSaIam"
      },
      {
        Action = [
          "eks:UpdateNodegroupVersion",
          "eks:UpdateNodegroupConfig",
          "eks:UpdateAddon",
          "eks:TagResource",
          "eks:ListNodegroups",
          "eks:ListAddons",
          "eks:DescribeUpdate",
          "eks:DescribeNodegroup",
          "eks:DescribeCluster",
          "eks:DescribeAddonVersions",
          "eks:DescribeAddonConfiguration",
          "eks:DescribeAddon",
          "eks:DeleteNodegroup",
          "eks:DeleteCluster",
          "eks:DeleteAddon",
          "eks:CreateNodegroup",
          "eks:CreateCluster",
          "eks:CreateAddon"
        ]
        Effect   = "Allow"
        Resource = "*"
        "Sid" : "CapaSaEks"
      },
      {
        Action = [
          "autoscaling:CreateOrUpdateTags"
        ]
        Effect   = "Allow"
        Resource = "*"
        "Sid" : "CapaSaEksAutoscaling"
      },
    ]
  })
}
