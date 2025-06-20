variable "region" {
  description = "AWS default region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_prefix" {
  type    = string
  default = ""
}

variable "vpc_public_subnets_name_prefix" {
  type    = string
  default = "upstream_vpc-public"
}

variable "assume_role_str" {
  description = "AWS assume-role arn - useful for runner contexts and shared system(s)"
  type        = string
  nullable    = true
  default     = ""
}

variable "custom_domain" {
  type    = string
  default = "kubesources.com"
}


variable "addition_tags" {
  type    = map(any)
  default = {}
}
# variable "tags" {
#   description = "Company required tags - used for billing metadata and cloud-related monitoring, automation"

#   type = object({
#     organization    = string
#     group           = string
#     team            = string
#     stack           = string
#     email           = string
#     application     = string
#     automation_tool = string

#     # organization    = "engineering"
#     # group           = "platform"
#     # team            = "enablement"
#     # stack           = "capi"
#     # email           = "test123@gmail.com"
#     # application     = "capi-cluster-manager-bootstrap-apps"
#     # automation_tool = "terraform"
#   })

#   validation {
#     condition     = (var.tags.organization != null) || (var.tags.group != null) || (var.tags.team != null) || (var.tags.stack != null) || (var.tags.email != null) || (var.tags.application != null) || (var.tags.automation_tool != null) || (var.tags.automation_path != null)
#     error_message = "All `var.tags` must be defined: \"group\", \"team\", \"stack\", \"email\", \"application\", \"automation_tool\", \"automation_path\""
#   }
# }

variable "tags" {
  type    = map(any)
  default = {}
}

variable "create" {
  description = "Controls if resources should be created (affects nearly all resources)"
  type        = bool
  default     = true
}

variable "default_helm_repo_parameter" {
  default = {
    helm_repo_chart     = "helm_repo_chart"
    helm_repo_name      = "helm_repo_name"
    helm_repo_namespace = "helm_repo_namespace"
    helm_repo_url       = "helm_repo_url"
    helm_repo_version   = "helm_repo_version"
    helm_repo_timeout   = "helm_repo_timeout"
  }
}

variable "default_helm_release_set_parameter" {
  # type = list(object({
  #   name  = string
  #   value = string
  # }))
  default = [
    {
      name  = "tolerations[0].key"
      value = "node-role.kubernetes.io/control-plane"
    },
    {
      name  = "tolerations[0].value"
      value = "true"
    },
    {
      name  = "tolerations[0].operator"
      value = "Equal"
    },
    {
      name  = "tolerations[0].effect"
      value = "NoSchedule"
    },
  ]
}

################################################################################
# Cluster
################################################################################

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "cluster-manager"
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

variable "create_metrics_server" {
  type    = bool
  default = false
}

variable "helm_release_metrics_server_parameter" {
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

variable "argocd_alb_ingress_parameter" {
  type    = map(any)
  default = {}
}

variable "argocd_elb_waf_acl_log_destination_configs_arn" {
  type    = string
  default = ""
}

variable "argocd_projects_roles" {
  default = []
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

variable "argocd_upstream_project_role" {
  default = "cluster-manager"
}

variable "argocd_upstream_application_config" {
  default = {}
}
variable "default_argocd_upstream_application_config_key" {
  default = {
    project               = "project"
    version_path          = "version_path"
    repo_url              = "repo_url"
    target_revision       = "target_revision"
    ext_var_key           = "ext_var_key"
    ext_var_value         = "ext_var_value"
    destination_namespace = "destination_namespace"
    destination_server    = "destination_server"
  }
}

# variable "argocd_keycloak_client_issuer" {
#   description = "keycloak issuer of argocd"
#   type        = string
#   default     = ""
# }
# variable "argocd_keycloak_client_id" {
#   description = "keycloak id of argocd"
#   type        = string
#   default     = ""
# }
