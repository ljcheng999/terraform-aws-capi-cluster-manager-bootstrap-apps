resource "aws_iam_role" "eks_assume_pod_identity" {
  name               = "${var.cluster_name}-eks-role"
  assume_role_policy = data.aws_iam_policy_document.pod_identity_document.json
}

resource "aws_iam_role_policy_attachment" "role-policy-attachment" {
  for_each = toset([
    "arn:aws:iam::aws:policy/PowerUserAccess",
  ])

  role       = aws_iam_role.eks_assume_pod_identity.name
  policy_arn = each.value
}

resource "aws_eks_pod_identity_association" "eks_pod_identity_auth_mode_association" {
  cluster_name    = var.cluster_name
  role_arn        = aws_iam_role.eks_assume_pod_identity.arn
  service_account = kubectl_manifest.eks_pod_identity_sa.name
  namespace       = kubectl_manifest.provision_namespace.name
}

resource "kubectl_manifest" "eks_pod_identity_sa" {
  yaml_body = <<-EOF
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: ${var.default_provision_name}
      namespace: ${kubectl_manifest.provision_namespace.name}
  EOF

  depends_on = [
    kubectl_manifest.provision_namespace,
  ]
}



