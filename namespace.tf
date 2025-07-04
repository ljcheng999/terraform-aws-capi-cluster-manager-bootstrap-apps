resource "kubectl_manifest" "provision_namespace" {
  yaml_body = <<-EOF
    apiVersion: v1
    kind: Namespace
    metadata:
      name: "${var.default_provision_namespace}"
  EOF

  depends_on = [
    helm_release.argocd,
  ]
}
