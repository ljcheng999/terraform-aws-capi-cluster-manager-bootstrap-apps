resource "time_static" "current_time" {}

resource "time_static" "one_hour_ahead" {
  rfc3339 = timeadd(time_static.current_time.rfc3339, "1h")
}

###############################################
#     ArgoCD Helm Chart
###############################################

resource "helm_release" "argo_cd" {
  count            = local.create && local.create_argocd ? 1 : 0
  create_namespace = local.create_argocd_namespace

  chart            = lookup(local.helm_release_argocd_parameter, var.default_helm_repo_parameter.helm_repo_chart, "argo-cd")
  name             = lookup(local.helm_release_argocd_parameter, var.default_helm_repo_parameter.helm_repo_name, "argo-cd")
  namespace        = lookup(local.helm_release_argocd_parameter, var.default_helm_repo_parameter.helm_repo_namespace, "argocd")
  repository       = lookup(local.helm_release_argocd_parameter, var.default_helm_repo_parameter.helm_repo_url, "https://argoproj.github.io/argo-helm")
  version          = lookup(local.helm_release_argocd_parameter, var.default_helm_repo_parameter.helm_repo_version, "8.0.0")
  timeout          = lookup(local.helm_release_argocd_parameter, var.default_helm_repo_parameter.helm_repo_timeout, 4000)

  wait             = true
  wait_for_jobs    = true
  max_history      = 3

  values = [
    templatefile("${path.module}/templates/helm/argocd-values.yaml", {
      argocd_admin_password         = "${bcrypt(aws_ssm_parameter.argo_admin_password[0].value)}",
      argocd_hostname               = "${local.argocd_endpoint}",
      argocd_elb_acm_arn            = "${local.create && local.create_argocd && local.create_argocd_cert ? aws_acm_certificate.argo_cert.0.arn: "" }",
      argo_cd_alb_waf_arn           = "${local.argocd_waf_arn ? "" : ""}",
    })
  ]
}

###############################################
#     ArgoCD UI secrets
###############################################
resource "aws_ssm_parameter" "argo_admin_password" {
  count     = local.create && local.create_argocd ? 1 : 0
  name      = "/cluster/${local.cluster_name}/secrets/argocd/admin_password"
  type      = "SecureString"
  value     = random_password.random_argo_admin_password[0].result

  tags = merge(
    {
      "Name": "/cluster/${local.cluster_name}/secrets/argocd/admin_password"
    },
    var.tags
  )
}

resource "random_password" "random_argo_admin_password" {
  count            = local.create && local.create_argocd ? 1 : 0
  length           = local.argocd_admin_password_length
  override_special = "!#$%&*()-_=+[]{}<>:?"
  special          = false

  lifecycle {
    ignore_changes = all
  }
}

# ###############################################
# #     ArgoCD route53
# ###############################################
resource "aws_acm_certificate" "argo_cert" {
  count                     = local.create && local.create_argocd && local.create_argocd_cert ? 1 : 0

  domain_name               = local.create_wildcard_argocd_cert ? "${local.custom_argocd_subdomain}.${local.custom_domain}" : local.argocd_endpoint
  subject_alternative_names = local.create_wildcard_argocd_cert ? ["*.${local.custom_argocd_subdomain}.${local.custom_domain}"] : null
  validation_method         = local.argocd_route53_validation_method

  tags = merge(
    {
      "Name": "${local.create_wildcard_argocd_cert ? "${local.custom_argocd_subdomain}.${local.custom_domain}" : local.argocd_endpoint}"
    },
    var.tags
  )
}


resource "aws_route53_record" "argo_validation" {
  count           = local.create && local.create_argocd && local.create_argocd_cert ? 1 : 0
  allow_overwrite = local.argocd_route53_validation_method_allow_overwrite

  name            = element(aws_acm_certificate.argo_cert.0.domain_validation_options.*.resource_record_name, count.index)
  type            = element(aws_acm_certificate.argo_cert.0.domain_validation_options.*.resource_record_type, count.index)
  records         = [element(aws_acm_certificate.argo_cert.0.domain_validation_options.*.resource_record_value, count.index)]
  ttl             = 60
  zone_id         = local.route53_zone_id

  depends_on = [
    aws_acm_certificate.argo_cert,
  ]
}

resource "aws_acm_certificate_validation" "argo" {
  count                   = local.create && local.create_argocd && local.create_argocd_cert ? 1 : 0

  certificate_arn         = aws_acm_certificate.argo_cert.0.arn
  validation_record_fqdns = aws_route53_record.argo_validation.*.fqdn
}


###############################################
#     ArgoCD Helm Chart
###############################################

# resource "helm_release" "argo_cd" {
#   count            = local.create && local.create_argocd ? 1 : 0
#   chart            = local.helm_release_argocd_helm_chart_name
#   create_namespace = local.create_argocd_namespace
#   name             = local.helm_release_argocd_helm_chart_name
#   namespace        = local.helm_release_argocd_helm_chart_namespace
#   repository       = local.helm_release_argocd_helm_chart_repo_location
#   version          = local.helm_release_argocd_helm_chart_version
#   timeout          = local.helm_release_argocd_timeout
#   wait             = true
#   wait_for_jobs    = true
#   max_history      = 3

#   values = [
#     templatefile("${path.module}/templates/helm/argocd-values.yaml", {
#       argocd_admin_password         = "${bcrypt(aws_ssm_parameter.argo_admin_password[0].value)}",
#       argocd_hostname               = "${local.argocd_endpoint}",
#       argocd_elb_acm_arn            = "${local.create && local.create_argocd && local.create_argocd_cert ? aws_acm_certificate.argo_cert.0.arn: "" }",
#       argo_cd_alb_waf_arn           = "${local.argocd_waf_arn ? "" : ""}",
#     })
#   ]
# }



# resource "kubernetes_manifest" "argo_project" {
#   computed_fields = [
#     "metadata.labels",
#     "metadata.annotations",
#     "metadata.finalizers"
#   ]

#   manifest = {
#     apiVersion = "argoproj.io/v1alpha1"
#     kind       = "AppProject"

#     metadata = {
#       name       = "${local.prefix}-${local.provision_environment}"
#       namespace = "argocd"
#       finalizers = var.cascade_delete ? ["resources-finalizer.argocd.argoproj.io"] : []
#     }

#     spec = {
#       description                = "${local.prefix}-${local.provision_environment} cluster manager Argo Project"
#       sourceRepos                = ["*"]
#       destinations               = [
#         {
#           server    = "https://kubernetes.default.svc"
#           namespace = "*"
#         }
#       ]

#       clusterResourceWhitelist   = var.default_cluster_resource_whitelist
#       namespaceResourceWhitelist = var.default_namespace_resource_whitelist
#       namespaceResourceBlacklist = var.default_namespace_resource_blacklist

#       roles = [
#         {
#           name = "${local.prefix}-${local.provision_environment}",
#           description = "${local.prefix}-${local.provision_environment}-default-role",
#           policies = [
#             "p, proj:${local.prefix}-${local.provision_environment}:${local.prefix}-${local.provision_environment}, applications, get, ${local.prefix}-${local.provision_environment}/*, allow",
#             "p, proj:${local.prefix}-${local.provision_environment}:${local.prefix}-${local.provision_environment}, applications, override, ${local.prefix}-${local.provision_environment}/*, allow",
#             "p, proj:${local.prefix}-${local.provision_environment}:${local.prefix}-${local.provision_environment}, applications, sync, ${local.prefix}-${local.provision_environment}/*, allow",
#             "p, proj:${local.prefix}-${local.provision_environment}:${local.prefix}-${local.provision_environment}, exec, * , ${local.prefix}-${local.provision_environment}/*, allow",
#             "p, proj:${local.prefix}-${local.provision_environment}:${local.prefix}-${local.provision_environment}, exec, * , ${local.prefix}-${local.provision_environment}/*, allow",
#           ],
#           jwtTokens = [
#             {
#               exp = time_static.one_hour_ahead.unix,
#               iat = time_static.current_time.unix,
#               id = "${local.prefix}-${local.provision_environment}-jwt-token",
#             }
#           ]
#         }
#       ]
#       # roles : [
#       #   for permission in var.default_permissions : {
#       #     name : permission["name"],
#       #     description : permission["description"],
#       #     policies : [
#       #       for policy in permission["policies"] :
#       #       "p, proj:${var.name}:${permission["name"]}, ${policy["resource"]}, ${policy["action"]}, ${var.name}/${policy["object"]}, allow"
#       #     ],
#       #     groups : permission["oidc_groups"]
#       #   }
#       # ]
#     }
#   }

#   depends_on = [
#     null_resource.argo_endpoint_wait,
#   ]
# }

# resource "kubernetes_manifest" "argo_application" {
#   computed_fields = [
#     "metadata.labels",
#     "metadata.annotations",
#     "metadata.finalizers"
#   ]

#   manifest = {
#     apiVersion = "argoproj.io/v1alpha1"
#     kind       = "Application"

#     metadata = {
#       name       = "${local.prefix}-${local.provision_environment}-kube"
#       namespace  = "argocd"
#       labels     = local.argocd_labels
#       finalizers = var.cascade_delete == true ? ["resources-finalizer.argocd.argoproj.io"] : []
#     }

#     spec = {
#       project = kubernetes_manifest.argo_project.manifest.metadata.name
#       source = {
#         repoURL         = var.repo_url_bfe_core_systems_capi             # https://gitlab.spectrumflow.net/digitalmarketing/infra/capi-core-systems/capi.git
#         targetRevision  = var.repo_target_revision_bfe_core_systems_capi # HEAD
#         # chart          = var.chart
#         path            = "kube-cm/${var.bfe_cluster_manager_version}"
#         # helm = {
#         #   releaseName = var.release_name == null ? var.name : var.release_name
#         #   parameters  = local.helm_parameters
#         #   values      = yamlencode(merge({ labels = local.labels }, var.helm_values))
#         # }
#       }

#       destination = {
#         namespace = "bfe-cluster-catalogs"
#         server    = "https://kubernetes.default.svc"
#       }
#       ignoreDifferences = var.argocd_ignore_differences
#       syncPolicy = {
#         automated = {
#           prune    = var.argocd_automated_prune
#           selfHeal = var.argocd_automated_self_heal
#         }
#         syncOptions = concat(var.argocd_sync_options, [
#           var.argocd_sync_option_validate ? "Validate=true" : "Validate=false",
#           var.argocd_sync_option_create_namespace ? "CreateNamespace=true" : "CreateNamespace=false",
#         ])
#         retry = {
#           limit = var.argocd_retry_limit
#           backoff = {
#             duration    = var.argocd_retry_backoff_duration
#             factor      = var.argocd_retry_backoff_factor
#             maxDuration = var.argocd_retry_backoff_max_duration
#           }
#         }
#       }
#       ignoreDifferences = var.argocd_ignore_differences
      
#     }
#   }

#   depends_on = [
#     null_resource.argo_endpoint_wait,
#   ]
# }


# resource "null_resource" "argo_endpoint_wait" {
#   provisioner "local-exec" {
#     command = templatefile("${path.module}/templates/scripts/endpoint_wait.tpl", {
#       URL = "https://${local.argocd_endpoint}",
#     })
#   }

#   depends_on = [
#     helm_release.argo_cd,
#   ]
# }



# ###############################################
# #     ArgoCD route53
# ###############################################
# resource "aws_acm_certificate" "argo_cert" {
#   count                     = var.create_argocd_cert ? 1 : 0
#   domain_name               = var.create_wildcard_argocd_cert ? var.core_domain : local.argocd_endpoint
#   subject_alternative_names = var.create_wildcard_argocd_cert ? ["*.${var.core_domain}"] : null
#   validation_method         = "DNS"

#   tags = var.tags
# }


# resource "aws_route53_record" "argo_validation" {
#   count           = var.create_argocd_cert ? 1 : 0
#   allow_overwrite = true
#   name            = element(aws_acm_certificate.argo_cert.0.domain_validation_options.*.resource_record_name, count.index)
#   type            = element(aws_acm_certificate.argo_cert.0.domain_validation_options.*.resource_record_type, count.index)
#   records         = [element(aws_acm_certificate.argo_cert.0.domain_validation_options.*.resource_record_value, count.index)]
#   ttl             = 60
#   zone_id         = var.core_system_zone_id

#   depends_on = [
#     aws_acm_certificate.argo_cert,
#   ]
# }

# resource "aws_acm_certificate_validation" "argo" {
#   count                   = var.create_argocd_cert ? 1 : 0
#   certificate_arn         = aws_acm_certificate.argo_cert.0.arn
#   validation_record_fqdns = aws_route53_record.argo_validation.*.fqdn
# }

# ###############################################
# #     ArgoCD UI secrets
# ###############################################
# resource "aws_ssm_parameter" "argo_admin_password" {
#   name      = "/${local.prefix}-${local.provision_environment}/argo/admin_password"
#   type      = "SecureString"
#   value     = random_password.argo_admin.result

#   tags = {
#     Name = "${local.prefix}-${local.provision_environment}-argo-admin-password"
#   }
# }

# resource "random_password" "argo_admin" {
#   length           = 16
#   override_special = "#!"
#   special          = true

#   lifecycle {
#     ignore_changes = all
#   }
# }

###############################################
#     ArgoCD Gitlab connection secrets
###############################################

# resource "argocd_repository_credentials" "bfe_core_systems_capi" {
#   password = var.repo_access_token_core_systems_capi
#   url      = var.repo_url_bfe_core_systems_capi # https://gitlab.spectrumflow.net/digitalmarketing/infra/capi-core-systems/capi.git

#   depends_on = [
#     kubernetes_manifest.argo_project.manifest.metadata,
#   ]
# }
