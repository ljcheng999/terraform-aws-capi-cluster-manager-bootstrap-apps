resource "helm_release" "velero" {
  count            = var.create && var.create_velero_controller ? 1 : 0
  create_namespace = true

  chart      = lookup(var.helm_release_velero_parameter, var.default_helm_repo_parameter.helm_repo_chart, "velero")
  name       = lookup(var.helm_release_velero_parameter, var.default_helm_repo_parameter.helm_repo_name, "velero")
  namespace  = lookup(var.helm_release_velero_parameter, var.default_helm_repo_parameter.helm_repo_namespace, "velero")
  repository = lookup(var.helm_release_velero_parameter, var.default_helm_repo_parameter.helm_repo_url, "https://vmware-tanzu.github.io/helm-charts/")
  version    = lookup(var.helm_release_velero_parameter, var.default_helm_repo_parameter.helm_repo_version, "10.0.1")
  timeout    = lookup(var.helm_release_velero_parameter, var.default_helm_repo_parameter.helm_repo_timeout, 4000)

  wait          = true
  wait_for_jobs = true
  max_history   = 3

  values = [templatefile("${path.module}/templates/helm/velero-values.yaml", {
    cloud_provider           = "${lookup(var.helm_release_velero_parameter, "cloud_provider", "aws")}",
    cloud_bucket             = "${lookup(var.helm_release_velero_parameter, "cloud_bucket", "velero-ljcheng-cluster-backups")}",
    cloud_bucket_folder_name = "${lookup(var.helm_release_velero_parameter, "cloud_bucket_folder_name", "core-kubesources-cluster-backups")}",
    cloud_region             = "${lookup(var.helm_release_velero_parameter, "cloud_region", "us-east-1")}",
    cloud_bucket_prefix      = "${var.cluster_name}",
    cloud_irsa_name          = "${var.helm_release_velero_serviceaccount_name}",
    cloud_irsa_arn           = "${aws_iam_role.velero_role[0].arn}"
    toleration_key           = "node.${var.custom_domain}/role",
    toleration_value         = "system",
  })]

  depends_on = [
    helm_release.metrics_server,
    helm_release.aws_elb_controller,
  ]
}

resource "aws_iam_policy" "amazon_eks_velero_policy" {
  count       = var.create && var.create_velero_controller ? 1 : 0
  name        = "${var.cluster_name}-eks-velero-operator-role-policy"
  description = "Policy for ${var.cluster_name} CAPI Cluster Velero policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:DescribeVolumes",
          "ec2:DescribeSnapshots",
          "ec2:CreateTags",
          "ec2:CreateVolume",
          "ec2:CreateSnapshot",
          "ec2:DeleteSnapshot"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:PutObject",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${lookup(var.helm_release_velero_parameter, "cloud_bucket", "velero-ljcheng-cluster-backups")}/*"
        ]
      },
      {
        Action = [
          "s3:ListBucket"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${lookup(var.helm_release_velero_parameter, "cloud_bucket", "velero-ljcheng-cluster-backups")}"
        ]
      },
    ]
  })

  tags = merge(
    {
      "Name" : "${var.cluster_name}-velero-role--policy"
    },
    var.tags,
  )
}

resource "aws_iam_role_policy_attachment" "velero_irsa_policy_attachment" {
  count      = var.create && var.create_velero_controller ? 1 : 0
  role       = aws_iam_role.velero_role[0].name
  policy_arn = aws_iam_policy.amazon_eks_velero_policy[0].arn
}

resource "aws_iam_role" "velero_role" {
  count              = var.create && var.create_velero_controller ? 1 : 0
  name               = "${var.cluster_name}-velero-operator-role"
  assume_role_policy = data.aws_iam_policy_document.velero_assume_role[0].json
}
