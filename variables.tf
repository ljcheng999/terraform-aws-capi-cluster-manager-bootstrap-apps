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
  type        = string
  default     = "kubesources.com"
}

variable "route53_zone_id" {
  type        = string
  default     = "Z02763451I8QENECRLHM9"
}

variable "addition_tags" {
  type    = map
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
  type        = list
  default     = []
}

variable "create" {
  description = "Controls if resources should be created (affects nearly all resources)"
  type        = bool
  default     = true
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
# Helm Charts Creation
################################################################################
### ArgoCD
################################################################################

variable "create_aws_elb_controller" {
  type        = bool
  default     = false
}

variable "create_external_secrets" {
  type        = bool
  default     = false
}

variable "create_argocd" {
  type        = bool
  default     = false
}

################################################################################
# Helm Charts Parameters
################################################################################
### ArgoCD
################################################################################

variable "helm_release_aws_elb_controller_parameter" {
  type        = map
  default     = {}
}


variable "helm_release_argocd_helm_chart_version" {
  type        = string
  default     = "7.9.0"
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
variable "argocd_endpoint" {
  description = "endpoint of argocd"
  type        = string
  default     = ""
}
variable "create_argocd_cert" {
  type        = bool
  default     = true
}
variable "create_wildcard_argocd_cert" {
  type        = bool
  default     = true
}
variable "argocd_waf_arn" {
  type        = string
  default     = ""
}

variable "custom_argocd_subdomain" {
  type        = string
  default     = "argocd"
}

################################################################################
### External Secrets
################################################################################

variable "helm_release_external_secrets_helm_chart_version" {
  type        = string
  default     = "0.16.0"
}

################################################################################
### Velero
################################################################################

variable "helm_release_velero_helm_revision" {
  type        = string
  default     = "8.3.0"
}
