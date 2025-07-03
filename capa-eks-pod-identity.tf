resource "aws_iam_role" "eks_pod_identity_auth_mode" {
  name               = "${var.cluster_name}-pod-identity-eks-role"
  assume_role_policy = data.aws_iam_policy_document.pod_identity_document.json
}

resource "aws_iam_role_policy_attachment" "role-policy-attachment" {
  for_each = toset([
    "arn:aws:iam::aws:policy/PowerUserAccess",
  ])

  role       = aws_iam_role.eks_pod_identity_auth_mode.name
  policy_arn = each.value
}

resource "aws_eks_pod_identity_association" "eks_pod_identity_auth_mode_association" {
  cluster_name    = var.cluster_name
  namespace       = kubectl_manifest.pod_identity_namespace.name
  service_account = kubectl_manifest.eks_pod_identity_sa.name
  role_arn        = aws_iam_role.eks_pod_identity_auth_mode.arn

  depends_on = [
    kubectl_manifest.pod_identity_namespace,
    kubectl_manifest.eks_pod_identity_sa,
  ]
}

resource "kubectl_manifest" "eks_pod_identity_sa" {
  yaml_body = <<-EOF
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: ${var.default_eks_pod_identity_eks_sa_name}
      namespace: ${kubectl_manifest.pod_identity_namespace.name}
  EOF

  depends_on = [
    kubectl_manifest.pod_identity_namespace,
  ]
}
resource "kubectl_manifest" "pod_identity_namespace" {
  yaml_body = <<-EOF
    apiVersion: v1
    kind: Namespace
    metadata:
      name: ${var.default_eks_pod_identity_eks_sa_namespace}
  EOF

  depends_on = [
    helm_release.argocd,
  ]
}
