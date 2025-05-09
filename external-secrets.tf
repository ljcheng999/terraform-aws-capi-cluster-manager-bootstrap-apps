
resource "helm_release" "external_secrets" {
  count            = local.create && local.create_external_secrets ? 1 : 0
  chart            = local.helm_release_external_secrets_helm_chart_name
  create_namespace = local.create_external_secrets_namespace
  name             = local.helm_release_external_secrets_name
  namespace        = local.helm_release_external_secrets_helm_chart_namespace
  repository       = local.helm_release_external_secrets_helm_repo_location
  timeout          = local.helm_release_external_secrets_timeout
  version          = local.helm_release_external_secrets_helm_chart_version
  wait             = true
  wait_for_jobs    = true
  max_history      = 3

  values = [
    "${file("${path.module}/templates/helm/external-secrets-values.yaml")}",
  ]
}

