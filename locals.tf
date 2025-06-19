locals {
  tags = {
    organization    = "engineering"
    group           = "platform"
    team            = "enablement"
    stack           = "capi"
    email           = "example.${var.custom_domain}"
    application     = "capi-cluster-manager-bootstrap-apps"
    automation_tool = "terraform"
  }
  addition_tags = var.addition_tags


  # core_account_public_subnet_ids_string = length(var.public_subnet_ids) == 0 ? join(",", var.core_account_public_subnet_ids) : ""

  argocd_admin_secret_path = "/cluster-manager/${var.cluster_name}/argocd/admin_password"

  argocd_elb_waf_acl_visibility_config = merge(
    var.argocd_elb_waf_acl_visibility_config,
    {
      "metric_name" : "${var.cluster_name}-argocd-waf-acl-cloudwatch-metrics"
    }
  )

  helm_release_velero_parameter = merge(
    var.helm_release_velero_parameter,
    {
      cloud_bucket             = "ljc-cluster-backups",
      cloud_bucket_folder_name = var.cluster_name,
      cloud_region             = var.region,
      cloud_bucket_prefix      = var.cluster_name,
    }
  )

}
