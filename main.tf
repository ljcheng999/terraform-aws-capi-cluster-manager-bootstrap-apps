provider "aws" {
  region = var.region

  # assume_role {
  #   role_arn = var.assume_role_str
  # }

}


module "capi_cluster_manager_bootstrap_app" {
  source = "../../modules/terraform-aws-capi-cluster-manager-bootstrap-apps"
  # source  = "ljcheng999/capi-cluster-manager-bootstrap-apps/aws"
  # version = "1.0.1"

  tags = merge(
    local.tags,
    local.addition_tags
  )

  create = var.create


  ### AWS ELB
  create_aws_elb_controller                 = var.create_aws_elb_controller
  helm_release_aws_elb_controller_parameter = var.helm_release_aws_elb_controller_parameter

  ### External Secrets
  create_external_secrets                 = var.create_external_secrets
  helm_release_external_secrets_parameter = var.helm_release_external_secrets_parameter

  ### Metrics Server
  create_metric_server                 = var.create_metric_server
  helm_release_metric_server_parameter = var.helm_release_metric_server_parameter

  ### Velero
  create_velero_controller      = var.create_velero_controller
  helm_release_velero_parameter = local.helm_release_velero_parameter


  # ### ArgoCD
  # create_argocd                               = var.create_argocd
  # helm_release_argocd_ingress_nginx_parameter = var.helm_release_argocd_ingress_nginx_parameter
  # helm_release_argocd_parameter               = var.helm_release_argocd_parameter

  # argocd_hostname                                = "${var.cluster_name}.${var.argocd_subdomain}.${var.custom_domain}"
  # argocd_admin_secret_path                       = local.argocd_admin_secret_path
  # argocd_elb_waf_name                            = "${var.cluster_name}-argocd-elb-waf"
  # argocd_elb_waf_acl_visibility_config           = local.argocd_elb_waf_acl_visibility_config
  # argocd_elb_waf_acl_resource_arn                = var.argocd_elb_waf_acl_resource_arn
  # argocd_elb_waf_acl_log_destination_configs_arn = var.argocd_elb_waf_acl_log_destination_configs_arn


  # # argocd_upstream_projects_roles     = var.argocd_upstream_projects_roles
  # # argocd_upstream_application_config = var.argocd_upstream_application_config

  create_argocd                               = var.create_argocd
  helm_release_argocd_ingress_nginx_parameter = var.helm_release_argocd_ingress_nginx_parameter
  helm_release_argocd_parameter               = var.helm_release_argocd_parameter

  argocd_hostname                                = "${var.cluster_name}.${var.argocd_subdomain}.${var.custom_domain}"
  argocd_keycloak_realm_name                     = var.argocd_keycloak_realm_name
  argocd_admin_secret_path                       = local.argocd_admin_secret_path
  argocd_elb_waf_name                            = "${var.cluster_name}-argocd-elb-waf"
  argocd_elb_waf_acl_visibility_config           = local.argocd_elb_waf_acl_visibility_config
  argocd_elb_waf_acl_resource_arn                = var.argocd_elb_waf_acl_resource_arn
  argocd_elb_waf_acl_log_destination_configs_arn = var.argocd_elb_waf_acl_log_destination_configs_arn

  argocd_upstream_projects_roles     = var.argocd_upstream_projects_roles
  argocd_upstream_application_config = var.argocd_upstream_application_config

}


output "resources" {
  value = module.capi_cluster_manager_bootstrap_app
  # sensitive = true
}





