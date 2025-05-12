

locals {
  create = var.create
  cluster_name                                        = var.cluster_name

  ### AWS ELB Controller
  create_aws_elb_controller                           = var.create_aws_elb_controller
  create_aws_elb_controller_namespace                 = var.create_aws_elb_controller_namespace
  helm_release_aws_elb_controller_parameter           = var.helm_release_aws_elb_controller_parameter
  
  ### External Secrets
  create_external_secrets                             = var.create_external_secrets
  create_external_secrets_namespace                   = var.create_external_secrets_namespace
  helm_release_external_secrets_parameter             = var.helm_release_external_secrets_parameter

  ### Velero
  create_velero_controller                            = var.create_velero_controller
  create_velero_namespace                             = var.create_velero_namespace
  helm_release_velero_parameter                       = var.helm_release_velero_parameter

  ### Metrics Server
  create_metrics_server_controller                    = var.create_metrics_server_controller
  create_metrics_server_controller_namespace          = var.create_metrics_server_controller_namespace
  helm_release_metrics_server_controller_parameter    = var.helm_release_metrics_server_controller_parameter


  #######################################################################################

  custom_domain                                       = var.custom_domain
  custom_argocd_subdomain                             = var.custom_argocd_subdomain
  route53_zone_id                                     = var.route53_zone_id

  ### ArgoCD
  argocd_admin_password_length                        = var.argocd_admin_password_length

  create_argocd                                       = var.create_argocd
  create_argocd_namespace                             = var.create_argocd_namespace
  helm_release_argocd_parameter                       = var.helm_release_argocd_parameter






  argocd_endpoint                                     = var.argocd_endpoint
  argocd_waf_arn                                      = var.argocd_waf_arn
  argocd_route53_validation_method                    = var.argocd_route53_validation_method
  argocd_route53_validation_method_allow_overwrite    = var.argocd_route53_validation_method_allow_overwrite


  
  final_acm_domain                                    = var.final_acm_domain
  final_kube_dashboard_acm_domain                     = var.final_kube_dashboard_acm_domain
  create_argocd_cert                                  = var.create_argocd_cert
  create_wildcard_argocd_cert                         = var.create_wildcard_argocd_cert
  public_subnet_ids                                   = var.public_subnet_ids


  

  # helm_release_velero_helm_repo                    = "https://vmware-tanzu.github.io/helm-charts"
  # helm_release_velero_helm_revision                = var.helm_release_velero_helm_revision
}