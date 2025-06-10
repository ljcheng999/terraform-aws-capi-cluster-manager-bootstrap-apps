

variable "create" {
  description = "Controls if resources should be created (affects nearly all resources)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "AWS VPC id"
  type        = string
  nullable    = true
  default     = ""
}

variable "vpc_prefix" {
  type    = string
  default = ""
}
variable "vpc_public_subnets_name_prefix" {
  type    = string
  default = ""
}

variable "custom_domain" {
  type    = string
  default = ""
}

variable "default_helm_repo_parameter" {
  type = map(any)
  default = {
    helm_repo_chart     = "helm_repo_chart"
    helm_repo_name      = "helm_repo_name_key"
    helm_repo_namespace = "helm_repo_namespace"
    helm_repo_url       = "helm_repo_url"
    helm_repo_version   = "helm_repo_version"
    helm_repo_timeout   = "helm_repo_timeout"
  }
}

################################################################################
# Cluster
################################################################################

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = ""
}

################################################################################
# Helm Charts Parameters
################################################################################

################################################################################
### AWS ELB Controller
################################################################################

variable "create_aws_elb_controller" {
  type    = bool
  default = false
}

variable "helm_release_aws_elb_controller_parameter" {
  type    = map(any)
  default = {}
}

variable "default_aws_elb_controller_ingress_class" {
  type    = string
  default = "alb"
}

################################################################################
### External Secrets
################################################################################

variable "create_external_secrets" {
  type    = bool
  default = false
}

variable "helm_release_external_secrets_parameter" {
  type    = map(any)
  default = {}
}

variable "helm_release_external_secrets_serviceaccount_name" {
  type    = string
  default = "es-irsa"
}

################################################################################
### Metrics Server
################################################################################

variable "create_metrics_server_controller" {
  type    = bool
  default = false
}

variable "helm_release_metrics_server_controller_parameter" {
  type    = map(any)
  default = {}
}

################################################################################
### Velero Controller
################################################################################

variable "create_velero_controller" {
  type    = bool
  default = false
}

variable "helm_release_velero_parameter" {
  type    = map(any)
  default = {}
}

variable "helm_release_velero_serviceaccount_name" {
  type    = string
  default = "velero-irsa"
}

################################################################################
### ArgoCD
################################################################################
variable "create_argocd" {
  type    = bool
  default = false
}

variable "helm_release_argocd_parameter" {
  type    = map(any)
  default = {}
}

variable "argocd_hostname" {
  type    = string
  default = ""
}

variable "argocd_admin_password_length" {
  type    = number
  default = 32
}

variable "argocd_ingress_classname" {
  type    = string
  default = ""
}
variable "argocd_admin_secret_params_name" {
  type    = string
  default = ""
}
variable "default_argocd_ingress_classname" {
  type    = string
  default = "argocd"
}

variable "helm_release_argocd_ingress_nginx_parameter" {
  type    = map(any)
  default = {}
}

variable "argocd_alb_ingress_parameter" {
  type    = map(any)
  default = {}
}

variable "argocd_elb_waf_name" {
  default = ""
}
variable "argocd_elb_waf_scope" {
  default = "REGIONAL"
}
variable "argocd_elb_waf_default_action" {
  default = "allow"
}
variable "argocd_elb_waf_rules" {
  default = []
}

variable "argocd_elb_waf_acl_visibility_config" {
  default = {}
}
variable "argocd_elb_waf_acl_resource_arn" {
  type    = list(any)
  default = []
}
variable "argocd_elb_waf_acl_enabled_logging_configuration" {
  type    = bool
  default = false
}

variable "argocd_elb_waf_acl_log_destination_configs_arn" {
  type    = string
  default = ""
}

variable "default_argocd_alb_ingress_parameter" {
  type = map(any)
  default = {
    argocd_alb_ingress_name      = "argocd_alb_ingress_name"
    argocd_alb_ingress_namespace = "argocd_alb_ingress_namespace"

    argocd_alb_ingress_healthcheck_path         = "argocd_alb_ingress_healthcheck_path"
    argocd_alb_ingress_load_balancer_attributes = "argocd_alb_ingress_load_balancer_attributes"
    argocd_alb_ingress_scheme                   = "argocd_alb_ingress_scheme"
    argocd_alb_ingress_security_groups          = "argocd_alb_ingress_security_groups"
    argocd_alb_ingress_ssl_policy               = "argocd_alb_ingress_ssl_policy"
    argocd_alb_ingress_success_codes            = "argocd_alb_ingress_success_codes"
    argocd_alb_ingress_target_type              = "argocd_alb_ingress_target_type"
    argocd_alb_ingress_waf_arn                  = "argocd_alb_ingress_waf_arn"
    argocd_alb_ingress_certificate_arn          = "argocd_alb_ingress_certificate_arn"
  }
}









