provider "aws" {
  region = var.region

  # assume_role {
  #   role_arn = var.assume_role_str
  # }

}


module "capi_cluster_manager_bootstrap_app" {
  # source  = "../../modules/terraform-aws-capi-cluster-manager-bootstrap-apps"
  source  = "ljcheng999/capi-cluster-manager-bootstrap-apps/aws"
  version = "1.0.0-beta10"

  create                                           = local.create
  cluster_name                                     = local.cluster_name
  route53_zone_id                                  = local.route53_zone_id
  
  ### AWS ELB
  create_aws_elb_controller                        = local.create_aws_elb_controller
  helm_release_aws_elb_controller_parameter        = local.helm_release_aws_elb_controller_parameter
  helm_release_aws_elb_controller_set_parameter    = local.helm_release_aws_elb_controller_set_parameter

  ### External Secrets
  create_external_secrets                          = local.create_external_secrets
  helm_release_external_secrets_parameter          = local.helm_release_external_secrets_parameter
  helm_release_external_secrets_set_parameter      = local.helm_release_external_secrets_set_parameter

  ### Velero
  create_velero_controller                         = local.create_velero_controller
  helm_release_velero_parameter                    = local.helm_release_velero_parameter
  helm_release_velero_set_parameter                = local.helm_release_velero_set_parameter














  ### ArgoCD
  create_argocd                                    = local.create_argocd
  argocd_endpoint                                  = local.argocd_endpoint
  create_argocd_cert                               = local.create_argocd_cert
  create_wildcard_argocd_cert                      = local.create_wildcard_argocd_cert
  argocd_waf_arn                                   = local.argocd_waf_arn

  public_subnet_ids                                = local.public_subnet_ids
  helm_release_argocd_helm_chart_version           = local.helm_release_argocd_helm_chart_version


  

  # tags = local.tags
  tags = merge(
    local.tags,
    local.addition_tags
  )
}


output "resources" {
  value = module.capi_cluster_manager_bootstrap_app
  # sensitive = true
}





