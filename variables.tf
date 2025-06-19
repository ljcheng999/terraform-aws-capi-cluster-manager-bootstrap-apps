variable "region" {
  description = "AWS default region"
  type        = string
  default     = "us-east-1"
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

variable "public_subnet_ids" {
  type    = list(any)
  default = []
}

variable "create" {
  description = "Controls if resources should be created (affects nearly all resources)"
  type        = bool
  default     = true
}

variable "default_helm_release_set_parameter" {
  # type = list(object({
  #   name  = string
  #   value = string
  # }))
  default = [
    {
      name  = "tolerations[0].key"
      value = "node-role.kubernetes.io/control-plan"
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

# variable "helm_release_aws_elb_controller_set_parameter" {
#   type = list(object({
#     name  = string
#     value = string
#   }))
#   default = []
# }

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

################################################################################
### Metric Server
################################################################################

variable "create_metric_server" {
  type    = bool
  default = false
}

variable "helm_release_metric_server_parameter" {
  type    = map(any)
  default = {}
}

################################################################################
### Velero
################################################################################
variable "create_velero_controller" {
  type    = bool
  default = false
}

variable "helm_release_velero_parameter" {
  type    = map(any)
  default = {}
}


################################################################################
### ArgoCD Ingress
################################################################################

variable "helm_release_argocd_ingress_nginx_parameter" {
  type    = map(any)
  default = {}
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

variable "argocd_subdomain" {
  type    = string
  default = "argocd"
}

variable "argocd_keycloak_client_issuer" {
  description = "keycloak issue of argocd client secret"
  type        = string
  default     = ""
}

variable "argocd_keycloak_realm_name" {
  type    = string
  default = ""
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
variable "argocd_upstream_projects_roles" {
  default = []
}

variable "argocd_upstream_application_config" {
  default = {
    project               = "cluster-manager"
    version_path          = ""
    repo_url              = "https://gitlab.spectrumflow.net/digitalmarketing/devops/terraform/capi/capi-upstream.git"
    target_revision       = "HEAD"
    ext_var               = "clusterManagementGroup"
    ext_var_value         = ""
    destination_namespace = "cluster-catalogs"
    destination_server    = "https://kubernetes.default.svc"
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
