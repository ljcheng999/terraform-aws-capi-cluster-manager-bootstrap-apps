
resource "helm_release" "metrics_server" {
  count            = var.create && var.create_metrics_server_controller ? 1 : 0
  create_namespace = true

  chart      = lookup(var.helm_release_metrics_server_controller_parameter, var.default_helm_repo_parameter.helm_repo_chart, "metrics-server")
  name       = lookup(var.helm_release_metrics_server_controller_parameter, var.default_helm_repo_parameter.helm_repo_name, "metrics-server")
  namespace  = lookup(var.helm_release_metrics_server_controller_parameter, var.default_helm_repo_parameter.helm_repo_namespace, "metrics-server")
  repository = lookup(var.helm_release_metrics_server_controller_parameter, var.default_helm_repo_parameter.helm_repo_url, "https://kubernetes-sigs.github.io/metrics-server")
  version    = lookup(var.helm_release_metrics_server_controller_parameter, var.default_helm_repo_parameter.helm_repo_version, "3.12.2")
  timeout    = lookup(var.helm_release_metrics_server_controller_parameter, var.default_helm_repo_parameter.helm_repo_timeout, 4000)

  wait          = true
  wait_for_jobs = true
  max_history   = 3

  values = [templatefile("${path.module}/templates/helm/metrics-server-values.yaml", {
    toleration_key   = "node.${var.custom_domain}/role",
    toleration_value = "system",
  })]

  depends_on = [
    helm_release.aws_elb_controller
  ]
}
