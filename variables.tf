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

variable "vpc_public_subnets_name_prefix" {
  type    = string
  default = ""
}

variable "custom_domain" {
  type    = string
  default = "kubesources.com"
}

variable "route53_zone_id" {
  type    = string
  default = "Z02763451I8QENECRLHM9"
}

variable "default_helm_repo_parameter" {
  type = map(any)
  default = {
    helm_repo_chart                        = "helm_repo_chart"
    helm_repo_name                         = "helm_repo_name_key"
    helm_repo_namespace                    = "helm_repo_namespace"
    helm_repo_url                          = "helm_repo_url"
    helm_repo_version                      = "helm_repo_version"
    helm_repo_timeout                      = 4000
    helm_repo_crd                          = null
    helm_repo_ingressclassname             = "helm_repo_ingressclassname"
    helm_repo_create_argocd_cert           = "helm_repo_create_argocd_cert"
    helm_repo_create_wildcard_argocd_cert  = "create_wildcard_argocd_cert"
    helm_repo_custom_argocd_subdomain      = "helm_repo_custom_argocd_subdomain"
    helm_repo_argocd_endpoint              = "helm_repo_argocd_endpoint"
    argocd_ingress_nginx_helm_repo_chart   = "argocd_ingress_nginx_helm_repo_chart"
    argocd_ingress_nginx_helm_repo_name    = "argocd_ingress_nginx_helm_repo_name"
    argocd_ingress_nginx_helm_repo_url     = "argocd_ingress_nginx_helm_repo_url"
    argocd_ingress_nginx_helm_repo_version = "argocd_ingress_nginx_helm_repo_version"
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

### ArgoCD
variable "create_argocd_controller" {
  type    = bool
  default = false
}
variable "create_argocd_ingress_nginx_controller" {
  type    = bool
  default = false
}

variable "create_argocd_namespace" {
  type    = bool
  default = true
}

variable "helm_release_argocd_controller_parameter" {
  type    = map(any)
  default = {}
}
variable "helm_release_argocd_ingress_nginx_parameter" {
  type    = map(any)
  default = {}
}
variable "argocd_subdomain" {
  type    = string
  default = "argocd"
}

variable "create_argocd_alb_ingress" {
  type    = bool
  default = false
}

variable "argocd_admin_password_length" {
  type    = number
  default = 24
}

variable "default_argocd_alb_ingress_parameter" {
  type = map(any)
  default = {
    aws_argocd_alb_ingress_create                   = "aws_argocd_alb_ingress_create"
    aws_argocd_alb_ingress_name                     = "aws_argocd_alb_ingress_name"
    aws_argocd_alb_ingress_namespace                = "aws_argocd_alb_ingress_namespace"
    aws_argocd_alb_ingress_classname                = "aws_argocd_alb_ingress_classname"
    aws_argocd_alb_ingress_waf_arn                  = "aws_argocd_alb_ingress_waf_arn"
    aws_argocd_alb_ingress_healthcheck_path         = "aws_argocd_alb_ingress_healthcheck_path"
    aws_argocd_alb_ingress_load_balancer_attributes = "aws_argocd_alb_ingress_load_balancer_attributes"
    aws_argocd_alb_ingress_certificate_arn          = "aws_argocd_alb_ingress_certificate_arn"
    aws_argocd_alb_ingress_scheme                   = "aws_argocd_alb_ingress_scheme"
    aws_argocd_alb_ingress_success_codes            = "aws_argocd_alb_ingress_success_codes"
    aws_argocd_alb_ingress_target_type              = "aws_argocd_alb_ingress_target_type"
    argocd_ingress_nginx_create                     = "argocd_ingress_nginx_create"
    argocd_ingress_nginx_helm_repo_chart            = "argocd_ingress_nginx_helm_repo_chart"
    argocd_ingress_nginx_helm_repo_name             = "argocd_ingress_nginx_helm_repo_name"
    argocd_ingress_nginx_helm_repo_namespace        = "argocd_ingress_nginx_helm_repo_namespace"
    argocd_ingress_nginx_helm_repo_url              = "argocd_ingress_nginx_helm_repo_url"
    argocd_ingress_nginx_helm_repo_version          = "argocd_ingress_nginx_helm_repo_version"
  }
}











# variable "custom_argocd_subdomain" {
#   type    = string
#   default = "argocd"
# }
# variable "create_argocd_cert" {
#   type    = bool
#   default = false
# }
# variable "create_wildcard_argocd_cert" {
#   type    = bool
#   default = true
# }
# variable "create_kube_dashboard_cert" {
#   type    = bool
#   default = false
# }
# variable "argocd_waf_arn" {
#   type    = string
#   default = ""
# }
# variable "public_subnet_ids" {
#   type    = list(any)
#   default = []
# }
# variable "final_acm_domain" {
#   type    = string
#   default = ""
# }
# variable "final_kube_dashboard_acm_domain" {
#   type    = string
#   default = ""
# }

# variable "argocd_route53_validation_method" {
#   type    = string
#   default = "DNS"
# }
# variable "argocd_route53_validation_method_allow_overwrite" {
#   type    = bool
#   default = true
# }




################################################################################
### External Secrets
################################################################################

variable "create_external_secrets" {
  type    = bool
  default = false
}
variable "create_external_secrets_namespace" {
  type    = bool
  default = true
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
### AWS ELB Controller
################################################################################

variable "create_aws_elb_controller" {
  type    = bool
  default = false
}
variable "create_aws_elb_controller_namespace" {
  type    = bool
  default = true
}
variable "helm_release_aws_elb_controller_parameter" {
  type = map(any)
  default = {
    helm_repo_namespace = "kube-system"
    helm_repo_url       = "https://aws.github.io/eks-charts"
    helm_repo_name      = "aws-load-balancer-controller"
    helm_repo_crd       = "github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds?ref=master"
    helm_repo_timeout   = 4000
    helm_repo_version   = "1.13.0"
  }
}

################################################################################
### Velero Controller
################################################################################

variable "create_velero_controller" {
  type    = bool
  default = false
}
variable "create_velero_namespace" {
  type    = bool
  default = true
}
variable "helm_release_velero_parameter" {
  type = map(any)
  default = {
    helm_repo_chart          = ""
    helm_repo_namespace      = ""
    helm_repo_url            = ""
    helm_repo_name           = ""
    helm_repo_crd            = null
    helm_repo_timeout        = 4000
    helm_repo_version        = ""
    cloud_provider           = ""
    cloud_bucket             = ""
    cloud_bucket_folder_name = ""
    cloud_region             = ""
    cloud_bucket_prefix      = ""
  }
}

variable "helm_release_velero_serviceaccount_name" {
  type    = string
  default = "velero-irsa"
}


################################################################################
### Metrics Server
################################################################################

variable "create_metrics_server_controller" {
  type    = bool
  default = false
}
variable "create_metrics_server_controller_namespace" {
  type    = bool
  default = true
}
variable "helm_release_metrics_server_controller_parameter" {
  type = map(any)
  default = {
    helm_repo_namespace = ""
    helm_repo_url       = ""
    helm_repo_name      = ""
    helm_repo_crd       = ""
    helm_repo_timeout   = 4000
    helm_repo_version   = ""
  }
}
