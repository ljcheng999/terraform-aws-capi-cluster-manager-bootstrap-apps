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
  addition_tags                                    = var.addition_tags


  create                                           = var.create
  cluster_name                                     = var.cluster_name
  route53_zone_id                                  = var.route53_zone_id
  custom_domain                                    = var.custom_domain

  ### AWS ELB
  create_aws_elb_controller                        = var.create_aws_elb_controller
  helm_release_aws_elb_controller_parameter        = var.helm_release_aws_elb_controller_parameter

  ### AWS ALB INGRESS
  create_aws_alb_ingress                           = var.create_aws_alb_ingress
  aws_alb_ingress_parameter                        = var.aws_alb_ingress_parameter

  ### External Secrets
  create_external_secrets                          = var.create_external_secrets
  helm_release_external_secrets_parameter          = var.helm_release_external_secrets_parameter

  ### Velero
  create_velero_controller                         = var.create_velero_controller
  helm_release_velero_parameter                    = var.helm_release_velero_parameter

  ### Metrics Server
  create_metrics_server_controller                 = var.create_metrics_server_controller
  helm_release_metrics_server_controller_parameter = var.helm_release_metrics_server_controller_parameter






  ### ArgoCD
  create_argocd                                    = var.create_argocd
  create_argocd_cert                               = var.create_argocd_cert
  create_wildcard_argocd_cert                      = var.create_wildcard_argocd_cert
  helm_release_argocd_helm_chart_version           = var.helm_release_argocd_helm_chart_version
  argocd_endpoint                                  = "${var.cluster_name}.${var.custom_argocd_subdomain}.${var.custom_domain}"
  argocd_waf_arn                                   = var.argocd_waf_arn


  public_subnet_ids                                = var.public_subnet_ids

  
}