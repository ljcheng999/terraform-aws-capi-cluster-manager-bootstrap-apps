resource "time_static" "current_time" {}

resource "time_static" "one_hour_ahead" {
  rfc3339 = timeadd(time_static.current_time.rfc3339, "1h")
}

###############################################
#     ArgoCD Helm Chart
###############################################

resource "helm_release" "argocd" {
  count            = local.create && local.create_argocd_controller ? 1 : 0
  create_namespace = var.create_argocd_namespace

  chart      = lookup(local.helm_release_argocd_controller_parameter, var.default_helm_repo_parameter.helm_repo_chart, "argo-cd")
  name       = lookup(local.helm_release_argocd_controller_parameter, var.default_helm_repo_parameter.helm_repo_name, "argo-cd")
  namespace  = lookup(local.helm_release_argocd_controller_parameter, var.default_helm_repo_parameter.helm_repo_namespace, "argocd")
  repository = lookup(local.helm_release_argocd_controller_parameter, var.default_helm_repo_parameter.helm_repo_url, "https://argoproj.github.io/argo-helm")
  version    = lookup(local.helm_release_argocd_controller_parameter, var.default_helm_repo_parameter.helm_repo_version, "8.0.0")
  timeout    = lookup(local.helm_release_argocd_controller_parameter, var.default_helm_repo_parameter.helm_repo_timeout, 4000)

  wait          = true
  wait_for_jobs = true
  max_history   = 3

  values = [
    templatefile("${path.module}/templates/helm/argocd-values.yaml", {
      cluster_name            = "${var.cluster_name}"
      argocd_admin_password   = "${bcrypt(aws_ssm_parameter.argo_admin_password[0].value)}",
      argocd_hostname         = "${local.argocd_hostname}",
      argocd_ingressclassname = lookup(local.helm_release_argocd_controller_parameter, var.default_helm_repo_parameter.helm_repo_ingressclassname, "argocd")
    })
  ]

  depends_on = [
    helm_release.aws_elb_controller,
    kubectl_manifest.aws_argocd_alb_ingress,
    kubectl_manifest.aws_alb_ingressclass,
  ]
}

###############################################
#     ArgoCD UI secrets
###############################################
resource "aws_ssm_parameter" "argo_admin_password" {
  count = local.create && local.create_argocd_controller ? 1 : 0
  name  = "/cluster/${local.cluster_name}/secrets/argocd/admin_password"
  type  = "SecureString"
  value = random_password.random_argo_admin_password[0].result

  tags = merge(
    {
      "Name" : "/cluster/${local.cluster_name}/secrets/argocd/admin_password"
    },
    var.tags
  )
}

resource "random_password" "random_argo_admin_password" {
  count            = local.create && local.create_argocd_controller ? 1 : 0
  length           = var.argocd_admin_password_length
  override_special = "!#$%&*()-_=+[]{}<>:?"
  special          = false

  lifecycle {
    ignore_changes = all
  }
}

# ###############################################
# #     ArgoCD AWS Components
# ###############################################

module "argocd_acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "5.1.1"


  create_certificate          = lookup(local.helm_release_argocd_controller_parameter, var.default_argocd_alb_ingress_parameter.aws_argocd_alb_ingress_create, false)
  create_route53_records_only = lookup(local.helm_release_argocd_controller_parameter, var.default_argocd_alb_ingress_parameter.aws_argocd_alb_ingress_create, false)
  domain_name                 = local.argocd_hostname
  zone_id                     = local.route53_zone_id

  subject_alternative_names = flatten([
    ["*.${var.argocd_subdomain}.${var.custom_domain}"],
  ])

  validation_method = "DNS"

  tags = merge(
    {
      "Name" : "${local.argocd_hostname}"
    },
    var.tags
  )
}

module "argo_alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  create = lookup(local.helm_release_argocd_controller_parameter, var.default_argocd_alb_ingress_parameter.aws_argocd_alb_ingress_create, false)

  name        = "${var.cluster_name}-argocd-sg"
  description = "Security group with all available arguments set for ArgoCD"
  vpc_id      = var.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = 6
      description = "public-argocd-ingress"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = 6
      description = "public-argocd-ingress"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  ingress_with_self = [
    {
      rule = "all-all"
    },
  ]

  egress_cidr_blocks = ["0.0.0.0/0"]
  tags = merge(
    {
      "Name" : "${var.cluster_name}-argocd-sg"
    },
    var.tags
  )
}

# alb.ingress.kubernetes.io/certificate-arn: "${lookup(local.helm_release_argocd_controller_parameter, var.default_argocd_alb_ingress_parameter.aws_argocd_alb_ingress_certificate_arn, "")}"
resource "kubectl_manifest" "aws_argocd_alb_ingress" {
  count     = local.create && local.create_aws_elb_controller && "${lookup(local.helm_release_argocd_controller_parameter, var.default_argocd_alb_ingress_parameter.aws_argocd_alb_ingress_create, false)}" ? 1 : 0
  yaml_body = <<-EOF
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      annotations:
        alb.ingress.kubernetes.io/actions.ssl-redirect: {"Type": "redirect", "RedirectConfig": { "Protocol": "HTTPS", "Port":"443", "StatusCode": "HTTP_301"}}
        alb.ingress.kubernetes.io/certificate-arn: "${module.argocd_acm.acm_certificate_arn}"
        alb.ingress.kubernetes.io/healthcheck-path: "${lookup(local.helm_release_argocd_controller_parameter, var.default_argocd_alb_ingress_parameter.aws_argocd_alb_ingress_healthcheck_path, "/healthz")}"
        alb.ingress.kubernetes.io/listen-ports: '[{"HTTP":80}, {"HTTPS":443}]'
        alb.ingress.kubernetes.io/load-balancer-attributes: "${lookup(local.helm_release_argocd_controller_parameter, var.default_argocd_alb_ingress_parameter.aws_argocd_alb_ingress_load_balancer_attributes, "idle_timeout.timeout_seconds=600")}"
        alb.ingress.kubernetes.io/manage-backend-security-group-rules: 'true'
        alb.ingress.kubernetes.io/scheme: "${lookup(local.helm_release_argocd_controller_parameter, var.default_argocd_alb_ingress_parameter.aws_argocd_alb_ingress_scheme, "internet-facing")}"
        alb.ingress.kubernetes.io/security-groups: "${module.argo_alb_sg.security_group_id}"
        alb.ingress.kubernetes.io/ssl-policy: ELBSecurityPolicy-TLS13-1-2-2021-06
        alb.ingress.kubernetes.io/subnets: "${lookup(local.helm_release_argocd_controller_parameter, var.default_argocd_alb_ingress_parameter.aws_argocd_alb_ingress_scheme, "internet-facing") == "internet-facing" ? "${join(",", data.aws_subnets.public_subnets[0].ids)}" : ""}
        alb.ingress.kubernetes.io/success-codes: "${lookup(local.helm_release_argocd_controller_parameter, var.default_argocd_alb_ingress_parameter.aws_argocd_alb_ingress_success_codes, "200")}"
        alb.ingress.kubernetes.io/target-type: "${lookup(local.helm_release_argocd_controller_parameter, var.default_argocd_alb_ingress_parameter.aws_argocd_alb_ingress_target_type, "instance")}"
        alb.ingress.kubernetes.io/wafv2-acl-arn: ${lookup(local.helm_release_argocd_controller_parameter, var.default_argocd_alb_ingress_parameter.aws_argocd_alb_ingress_waf_arn, "alb")}
      name: ${lookup(local.helm_release_argocd_controller_parameter, var.default_argocd_alb_ingress_parameter.aws_argocd_alb_ingress_name, "${var.cluster_name}-argocd-alb-ingress")}
      namespace: ${lookup(local.helm_release_argocd_controller_parameter, var.default_argocd_alb_ingress_parameter.aws_argocd_alb_ingress_namespace, "kube-system")}
    spec:
      ingressClassName: ${lookup(local.helm_release_argocd_controller_parameter, var.default_argocd_alb_ingress_parameter.aws_argocd_alb_ingress_classname, "alb")}
      rules:
      - http:
          paths:
            - backend:
                service:
                  name: ssl-redirect
                  port:
                    name: use-annotation
              path: /*
              pathType: ImplementationSpecific
            - backend:
                service:
                  name: ingress-nginx-fw-controller
                  port:
                    number: 80
              path: /*
              pathType: ImplementationSpecific
    EOF

  depends_on = [
    helm_release.aws_elb_controller
  ]
}

# module "acm" {
#   source  = "terraform-aws-modules/acm/aws"
#   version = "~> 4.0"

#   create_certificate = local.create && local.create_aws_elb_controller && var.create_aws_alb_ingress ? true : false

#   domain_name  = var.custom_domain
#   zone_id      = var.route53_zone_id

#   validation_method = "DNS"

#   subject_alternative_names = [
#     "*.${var.custom_domain}",
#     "*.argocd.${var.custom_domain}",
#   ]

#   wait_for_validation = true
#   create_route53_records  = false

#   tags = var.tags
# }

# module "route53_records" {
#   source  = "terraform-aws-modules/acm/aws"
#   version = "~> 4.0"

#   # providers = {
#   #   aws = aws.route53
#   # }

#   create_certificate          = false
#   create_route53_records_only = true

#   validation_method = "DNS"

#   distinct_domain_names = module.acm.distinct_domain_names
#   zone_id               = "Z266PL4W4W6MSG"

#   acm_certificate_domain_validation_options = module.acm.acm_certificate_domain_validation_options
# }



# apiVersion: networking.k8s.io/v1
# kind: Ingress
# metadata:
#   annotations:
#     alb.ingress.kubernetes.io/actions.whoami: >-
#       {"Type": "fixed-response", "FixedResponseConfig": { "ContentType":
#       "text/plain", "StatusCode": "200", "MessageBody": "You are talking to
#       primary external FE alb"}}
#     alb.ingress.kubernetes.io/certificate-arn: >-
#       arn:aws:acm:us-east-1:533267295140:certificate/751b4eec-8651-456f-bf69-9fed92f9fae4
#     alb.ingress.kubernetes.io/healthcheck-path: /healthz
#     alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS":443}]'
#     alb.ingress.kubernetes.io/load-balancer-attributes: >-
#       idle_timeout.timeout_seconds=600,access_logs.s3.enabled=true,access_logs.s3.bucket=phoenix-lowers-lbs-logs,access_logs.s3.prefix=poc-nginx-fe-dev-primary-external-alb
#     alb.ingress.kubernetes.io/manage-backend-security-group-rules: 'true'
#     alb.ingress.kubernetes.io/scheme: internet-facing
#     alb.ingress.kubernetes.io/security-groups: sg-01e22d87557201771
#     alb.ingress.kubernetes.io/ssl-policy: ELBSecurityPolicy-TLS13-1-2-2021-06
#     alb.ingress.kubernetes.io/subnets: >-
#       subnet-0d37b5ed7cd0a38d2,subnet-03ce7b143a6e9be32,subnet-0878c6b25e72eb1f0,subnet-0b9db6423b35e6719
#     alb.ingress.kubernetes.io/success-codes: '200'
#     alb.ingress.kubernetes.io/target-type: instance
#     alb.ingress.kubernetes.io/wafv2-acl-arn: >-
#       arn:aws:wafv2:us-east-1:533267295140:regional/webacl/buyflow-dev-cluster-open-acl/e3d337d9-67e4-42f8-af5e-78725964e012
#   finalizers:
#     - ingress.k8s.aws/resources
#   name: nginx-fe-dev-primary-external-alb-ingress
#   namespace: nginx
# spec:
#   ingressClassName: alb
#   rules:
#     - http:
#         paths:
#           - backend:
#               service:
#                 name: whoami
#                 port:
#                   name: use-annotation
#             path: /whoami
#             pathType: ImplementationSpecific
#           - backend:
#               service:
#                 name: ingress-nginx-fe-dev-primary-external-controller
#                 port:
#                   number: 80
#             path: /*
#             pathType: ImplementationSpecific


# resource "aws_acm_certificate" "argocd_cert" {
#   count = local.create && local.create_argocd_controller && lookup(local.helm_release_argocd_controller_parameter, var.default_helm_repo_parameter.helm_repo_create_argocd_cert, false) ? 1 : 0

#   domain_name = local.argocd_hostname
#   subject_alternative_names = flatten([
#     ["*.${var.argocd_subdomain}.${var.custom_domain}"],
#   ])
#   validation_method = var.argocd_route53_validation_method

#   lifecycle {
#     create_before_destroy = true
#   }

#   tags = merge(
#     {
#       "Name" : "${local.argocd_hostname}"
#     },
#     var.tags
#   )
# }



# resource "aws_route53_record" "argo_validation" {
#   count           = local.create && local.create_argocd_controller && lookup(local.helm_release_argocd_controller_parameter, var.default_helm_repo_parameter.helm_repo_create_argocd_cert, false) ? 1 : 0
#   allow_overwrite = var.argocd_route53_validation_method_allow_overwrite

#   name    = element(aws_acm_certificate.argocd_cert.0.domain_validation_options.*.resource_record_name, count.index)
#   type    = element(aws_acm_certificate.argocd_cert.0.domain_validation_options.*.resource_record_type, count.index)
#   records = [element(aws_acm_certificate.argocd_cert.0.domain_validation_options.*.resource_record_value, count.index)]
#   ttl     = 60
#   zone_id = local.route53_zone_id

#   depends_on = [
#     aws_acm_certificate.argocd_cert,
#   ]
# }

# resource "aws_acm_certificate_validation" "argo" {
#   count = local.create && local.create_argocd_controller && lookup(local.helm_release_argocd_controller_parameter, var.default_helm_repo_parameter.helm_repo_create_argocd_cert, false) ? 1 : 0

#   certificate_arn         = aws_acm_certificate.argocd_cert.0.arn
#   validation_record_fqdns = aws_route53_record.argo_validation.*.fqdn

#   depends_on = [
#     aws_route53_record.argo_validation,
#   ]
# }


###############################################
#     ArgoCD Helm Chart
###############################################


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
