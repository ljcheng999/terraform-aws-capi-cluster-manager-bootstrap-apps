

locals {
  create            = var.create
  cluster_name      = var.cluster_name
  public_subnet_ids = var.public_subnet_ids

  ### AWS ELB Controller
  create_aws_elb_controller                 = var.create_aws_elb_controller
  create_aws_elb_controller_namespace       = var.create_aws_elb_controller_namespace
  helm_release_aws_elb_controller_parameter = var.helm_release_aws_elb_controller_parameter

  ### External Secrets
  create_external_secrets                 = var.create_external_secrets
  helm_release_external_secrets_parameter = var.helm_release_external_secrets_parameter

  ### Velero
  create_velero_controller      = var.create_velero_controller
  helm_release_velero_parameter = var.helm_release_velero_parameter

  ### Metrics Server
  create_metrics_server_controller                 = var.create_metrics_server_controller
  create_metrics_server_controller_namespace       = var.create_metrics_server_controller_namespace
  helm_release_metrics_server_controller_parameter = var.helm_release_metrics_server_controller_parameter


  #######################################################################################

  custom_domain   = var.custom_domain
  route53_zone_id = var.route53_zone_id

  ### ArgoCD
  create_argocd_controller                 = var.create_argocd_controller
  helm_release_argocd_controller_parameter = var.helm_release_argocd_controller_parameter
  argocd_hostname                          = "${lookup(local.helm_release_argocd_controller_parameter, var.default_helm_repo_parameter.helm_repo_custom_argocd_subdomain, "ljcheng")}.${var.argocd_subdomain}.${var.custom_domain}"





}
