
resource "helm_release" "external_secrets" {
  count            = local.create && local.create_external_secrets ? 1 : 0

  # create_namespace = local.create_external_secrets_namespace

  create_namespace = lookup(local.helm_release_external_secrets_parameter, var.default_helm_repo_parameter.create_namespace, false)
  chart            = lookup(local.helm_release_external_secrets_parameter, var.default_helm_repo_parameter.helm_repo_name, "external-secrets")
  name             = lookup(local.helm_release_external_secrets_parameter, var.default_helm_repo_parameter.helm_repo_name, "external-secrets")
  namespace        = lookup(local.helm_release_external_secrets_parameter, var.default_helm_repo_parameter.helm_repo_namespace, "external-secrets")
  repository       = lookup(local.helm_release_external_secrets_parameter, var.default_helm_repo_parameter.helm_repo_url, "https://charts.external-secrets.io")
  version          = lookup(local.helm_release_external_secrets_parameter, var.default_helm_repo_parameter.helm_repo_version, "0.16.1")
  timeout          = lookup(local.helm_release_external_secrets_parameter, var.default_helm_repo_parameter.helm_repo_timeout, 4000)

  wait             = true
  wait_for_jobs    = true
  max_history      = 3
  
  dynamic "set" {
   for_each = length(local.helm_release_external_secrets_set_parameter) > 0 ? local.helm_release_external_secrets_set_parameter : []
    content {
      name = set.value.name
      value = set.value.value
    }
  }

  # values = [
  #   "${file("${path.module}/templates/helm/external-secrets-values.yaml")}",
  # ]
}

