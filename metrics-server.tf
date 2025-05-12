
resource "helm_release" "metrics_server" {
  count            = local.create && local.create_metrics_server_controller ? 1 : 0
  create_namespace = local.create_metrics_server_controller_namespace

  chart            = lookup(local.helm_release_metrics_server_controller_parameter, var.default_helm_repo_parameter.helm_repo_chart, "metrics-server")
  name             = lookup(local.helm_release_metrics_server_controller_parameter, var.default_helm_repo_parameter.helm_repo_name, "metrics-server")
  namespace        = lookup(local.helm_release_metrics_server_controller_parameter, var.default_helm_repo_parameter.helm_repo_namespace, "metrics-server")
  repository       = lookup(local.helm_release_metrics_server_controller_parameter, var.default_helm_repo_parameter.helm_repo_url, "https://kubernetes-sigs.github.io/metrics-server")
  version          = lookup(local.helm_release_metrics_server_controller_parameter, var.default_helm_repo_parameter.helm_repo_version, "3.12.2")
  timeout          = lookup(local.helm_release_metrics_server_controller_parameter, var.default_helm_repo_parameter.helm_repo_timeout, 4000)

  wait             = true
  wait_for_jobs    = true
  max_history      = 3

  values = [templatefile("${path.module}/templates/helm/metrics-server.yaml", {})]
}