
resource "helm_release" "velero" {
  count            = local.create && local.create_velero_controller ? 1 : 0
  create_namespace = local.create_velero_namespace

  chart            = lookup(local.helm_release_velero_parameter, var.default_helm_repo_parameter.helm_repo_name, "vmware-tanzu")
  name             = lookup(local.helm_release_velero_parameter, var.default_helm_repo_parameter.helm_repo_name, "velero")
  namespace        = lookup(local.helm_release_velero_parameter, var.default_helm_repo_parameter.helm_repo_namespace, "velero")
  repository       = lookup(local.helm_release_velero_parameter, var.default_helm_repo_parameter.helm_repo_url, "https://vmware-tanzu.github.io/helm-charts/")
  version          = lookup(local.helm_release_velero_parameter, var.default_helm_repo_parameter.helm_repo_version, "9.1.2")
  timeout          = lookup(local.helm_release_velero_parameter, var.default_helm_repo_parameter.helm_repo_timeout, 4000)

  wait             = true
  wait_for_jobs    = true
  max_history      = 3
  
  dynamic "set" {
   for_each = length(local.helm_release_velero_set_parameter) > 0 ? local.helm_release_velero_set_parameter : []
    content {
      name = set.value.name
      value = set.value.value
    }
  }

  values = [templatefile("${path.module}/templates/helm/velero.yaml", {
    cloud_provider            = lookup(local.helm_release_velero_parameter, "cloud_provider", "aws")
    cloud_bucket              = lookup(local.helm_release_velero_parameter, "cloud_bucket", "ljc-cluster-backups")
    cloud_bucket_folder_name  = lookup(local.helm_release_velero_parameter, "cloud_bucket_folder_name", "core-kubesources-cluster-backups")
    cloud_region              = lookup(local.helm_release_velero_parameter, "cloud_region", "us-east-1")
    cloud_bucket_prefix       = var.cluster_name
  })]
}

