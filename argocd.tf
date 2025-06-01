resource "time_static" "current_time" {}

resource "time_static" "one_hour_ahead" {
  rfc3339 = timeadd(time_static.current_time.rfc3339, "1h")
}

# ###############################################
# #     ArgoCD Helm Chart
# ###############################################

resource "helm_release" "argocd" {
  count            = var.create && var.create_argocd ? 1 : 0
  create_namespace = true

  chart      = lookup(var.helm_release_argocd_parameter, var.default_helm_repo_parameter.helm_repo_chart, "argo-cd")
  name       = lookup(var.helm_release_argocd_parameter, var.default_helm_repo_parameter.helm_repo_name, "argo-cd")
  namespace  = lookup(var.helm_release_argocd_parameter, var.default_helm_repo_parameter.helm_repo_namespace, "argocd")
  repository = lookup(var.helm_release_argocd_parameter, var.default_helm_repo_parameter.helm_repo_url, "https://argoproj.github.io/argo-helm")
  version    = lookup(var.helm_release_argocd_parameter, var.default_helm_repo_parameter.helm_repo_version, "8.0.0")
  timeout    = lookup(var.helm_release_argocd_parameter, var.default_helm_repo_parameter.helm_repo_timeout, 4000)

  wait          = true
  wait_for_jobs = true
  max_history   = 3

  values = [
    templatefile("${path.module}/templates/helm/argocd-values.yaml", {
      cluster_name             = "${var.cluster_name}"
      argocd_admin_password    = "${bcrypt(aws_ssm_parameter.argo_admin_password[0].value)}",
      argocd_hostname          = "${var.argocd_hostname}",
      argocd_ingress_classname = "${var.argocd_ingress_classname != "" ? var.argocd_ingress_classname : var.default_argocd_ingress_classname}",
      toleration_key           = "node.${var.custom_domain}/role",
      toleration_value         = "system",
    })
  ]

  depends_on = [
    helm_release.aws_elb_controller,
    helm_release.argocd_nginx_ingress,
    # kubernetes_ingress_v1.aws_argocd_alb_ingress,
    # kubectl_manifest.aws_argocd_alb_ingress,
    # kubectl_manifest.aws_alb_ingressclass,
  ]
}

# ###############################################
# #     Ingress-Nginx Helm Chart for ArgoCD
# ###############################################

resource "helm_release" "argocd_nginx_ingress" {
  count            = var.create && var.create_argocd ? 1 : 0
  create_namespace = true

  chart      = lookup(var.helm_release_argocd_ingress_nginx_parameter, var.default_helm_repo_parameter.helm_repo_chart, "ingress-nginx")
  name       = lookup(var.helm_release_argocd_ingress_nginx_parameter, var.default_helm_repo_parameter.helm_repo_name, "${var.cluster_name}-argocd-ingress-nginx")
  namespace  = lookup(var.helm_release_argocd_ingress_nginx_parameter, var.default_helm_repo_parameter.helm_repo_namespace, "nginx")
  repository = lookup(var.helm_release_argocd_ingress_nginx_parameter, var.default_helm_repo_parameter.helm_repo_url, "https://kubernetes.github.io/ingress-nginx")
  version    = lookup(var.helm_release_argocd_ingress_nginx_parameter, var.default_helm_repo_parameter.helm_repo_version, "4.12.2")
  timeout    = lookup(var.helm_release_argocd_ingress_nginx_parameter, var.default_helm_repo_parameter.helm_repo_timeout, 4000)

  wait          = true
  wait_for_jobs = true
  max_history   = 3

  values = [
    templatefile("${path.module}/templates/helm/argocd-nginx-ingress-values.yaml", {
      cluster_name             = "${var.cluster_name}",
      argocd_ingress_classname = "${var.argocd_ingress_classname != "" ? var.argocd_ingress_classname : var.default_argocd_ingress_classname}",
      toleration_key           = "node.${var.custom_domain}/role",
      toleration_value         = "system",
    })
  ]

  depends_on = [
    helm_release.aws_elb_controller,
    helm_release.metrics_server,
  ]
}

# ###############################################
# #     AWS ELB for ArgoCD
# ###############################################

resource "kubernetes_ingress_v1" "argocd_elb_ingress" {
  count = var.create && var.create_argocd ? 1 : 0
  metadata {
    name      = lookup(var.argocd_alb_ingress_parameter, var.default_argocd_alb_ingress_parameter.argocd_alb_ingress_name, "${var.cluster_name}-argocd-ingress-nginx-controller")
    namespace = lookup(var.argocd_alb_ingress_parameter, var.default_argocd_alb_ingress_parameter.argocd_alb_ingress_namespace, "nginx")
    annotations = {
      "alb.ingress.kubernetes.io/actions.ssl-redirect"                = <<JSON
      {
        "Type": "redirect",
        "RedirectConfig": {
          "Protocol": "HTTPS",
          "Port": "443",
          "StatusCode": "HTTP_301"
        }
      }
      JSON
      "alb.ingress.kubernetes.io/certificate-arn"                     = "${lookup(var.argocd_alb_ingress_parameter, var.default_argocd_alb_ingress_parameter.argocd_alb_ingress_certificate_arn, "") == "" ? "${module.argocd_acm.acm_certificate_arn}" : ""}"
      "alb.ingress.kubernetes.io/healthcheck-path"                    = "${lookup(var.argocd_alb_ingress_parameter, var.default_argocd_alb_ingress_parameter.argocd_alb_ingress_healthcheck_path, "/healthz")}"
      "alb.ingress.kubernetes.io/listen-ports"                        = <<JSON
      [
        {"HTTP": 80},
        {"HTTPS": 443}
      ]
      JSON
      "alb.ingress.kubernetes.io/load-balancer-attributes"            = "${lookup(var.argocd_alb_ingress_parameter, var.default_argocd_alb_ingress_parameter.argocd_alb_ingress_load_balancer_attributes, "idle_timeout.timeout_seconds=600")}"
      "alb.ingress.kubernetes.io/manage-backend-security-group-rules" = true
      "alb.ingress.kubernetes.io/scheme"                              = "${lookup(var.argocd_alb_ingress_parameter, var.default_argocd_alb_ingress_parameter.argocd_alb_ingress_scheme, "internet-facing")}"
      "alb.ingress.kubernetes.io/security-groups"                     = "${lookup(var.argocd_alb_ingress_parameter, var.default_argocd_alb_ingress_parameter.argocd_alb_ingress_security_groups, "") == "" ? "${module.argocd_elb_sg[0].security_group_id}" : ""}"
      "alb.ingress.kubernetes.io/ssl-policy"                          = "${lookup(var.argocd_alb_ingress_parameter, var.default_argocd_alb_ingress_parameter.argocd_alb_ingress_ssl_policy, "ELBSecurityPolicy-TLS13-1-2-2021-06")}"
      "alb.ingress.kubernetes.io/subnets"                             = "${lookup(var.argocd_alb_ingress_parameter, var.default_argocd_alb_ingress_parameter.argocd_alb_ingress_scheme, "internet-facing") == "internet-facing" ? "${join(",", data.aws_subnets.public_subnets[0].ids)}" : ""}"
      "alb.ingress.kubernetes.io/success-codes"                       = "${lookup(var.argocd_alb_ingress_parameter, var.default_argocd_alb_ingress_parameter.argocd_alb_ingress_success_codes, "200")}"
      "alb.ingress.kubernetes.io/target-type"                         = "${lookup(var.argocd_alb_ingress_parameter, var.default_argocd_alb_ingress_parameter.argocd_alb_ingress_target_type, "instance")}"
      "alb.ingress.kubernetes.io/wafv2-acl-arn"                       = "${lookup(var.argocd_alb_ingress_parameter, var.default_argocd_alb_ingress_parameter.argocd_alb_ingress_waf_arn, "") == "" ? "${module.wafv2[0].aws_wafv2_arn}" : ""}"
    }
  }

  spec {
    ingress_class_name = var.default_aws_elb_controller_ingress_class
    rule {
      http {
        path {
          backend {
            service {
              name = "ssl-redirect"
              port {
                name = "use-annotation"
              }
            }
          }
          path = "/*"
        }
        path {
          backend {
            service {
              name = lookup(var.argocd_alb_ingress_parameter, var.default_argocd_alb_ingress_parameter.argocd_alb_ingress_name, "${var.cluster_name}-argocd-ingress-nginx-controller")
              port {
                number = 80
              }
            }
          }
          path = "/*"
        }
      }
    }
  }

  wait_for_load_balancer = true
  depends_on = [
    helm_release.aws_elb_controller,
    helm_release.argocd,
  ]
}

# ###############################################
# #     ArgoCD UI admin secrets
# ###############################################
resource "aws_ssm_parameter" "argo_admin_password" {
  count = var.create && var.create_argocd ? 1 : 0
  name  = var.argocd_admin_secret_params_name
  type  = "SecureString"
  value = random_password.random_argo_admin_password[0].result

  tags = merge(
    {
      "Name" : "/cluster/${var.cluster_name}/secrets/argocd/admin_password"
    },
    var.tags
  )
}

resource "random_password" "random_argo_admin_password" {
  count            = var.create && var.create_argocd ? 1 : 0
  length           = var.argocd_admin_password_length
  override_special = "!#$%&*()-_=+[]{}<>:?"
  special          = false

  lifecycle {
    ignore_changes = all
  }
}



# # ###############################################
# # #     ArgoCD AWS Components
# # ###############################################
module "argocd_elb_sg" {
  count   = var.create && var.create_argocd ? 1 : 0
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  create = lookup(var.argocd_alb_ingress_parameter, var.default_argocd_alb_ingress_parameter.argocd_alb_ingress_security_groups, "") == "" ? true : false


  name        = "${var.cluster_name}-argocd-elb-sg"
  description = "Security group with all available arguments set for ArgoCD"
  vpc_id      = data.aws_vpc.selected.id

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

module "argocd_acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "5.1.1"

  create_certificate          = lookup(var.argocd_alb_ingress_parameter, var.default_argocd_alb_ingress_parameter.argocd_alb_ingress_certificate_arn, "") == "" ? true : false
  create_route53_records_only = false
  domain_name                 = var.argocd_hostname
  zone_id                     = data.aws_route53_zone.route53_zone.id

  subject_alternative_names = flatten([
    ["*.${var.custom_domain}"],
  ])

  validation_method = "DNS"

  tags = merge(
    {
      "Name" : "${var.argocd_hostname}"
    },
    var.tags
  )
}

module "wafv2" {
  count   = lookup(var.argocd_alb_ingress_parameter, var.default_argocd_alb_ingress_parameter.argocd_alb_ingress_waf_arn, "") == "" ? 1 : 0
  source  = "aws-ss/wafv2/aws"
  version = "3.8.1"

  name  = var.argocd_elb_waf_name
  scope = var.argocd_elb_waf_scope

  default_action                = var.argocd_elb_waf_default_action
  rule                          = var.argocd_elb_waf_rules
  visibility_config             = var.argocd_elb_waf_acl_visibility_config
  resource_arn                  = var.argocd_elb_waf_acl_resource_arn
  enabled_logging_configuration = var.argocd_elb_waf_acl_enabled_logging_configuration
  log_destination_configs       = var.argocd_elb_waf_acl_log_destination_configs_arn == "" ? module.log_group[0].cloudwatch_log_group_arn : var.argocd_elb_waf_acl_log_destination_configs_arn
}

module "log_group" {
  count   = lookup(var.argocd_alb_ingress_parameter, var.default_argocd_alb_ingress_parameter.argocd_alb_ingress_waf_arn, "") == "" ? 1 : 0
  source  = "terraform-aws-modules/cloudwatch/aws//modules/log-group"
  version = "~> 3.0"

  name              = "aws-waf-logs-${var.argocd_elb_waf_name}"
  retention_in_days = 7
}

# ###############################################
# #     ArgoCD UI route53
# ###############################################
resource "aws_route53_record" "argocd_cname_record" {
  count   = var.create && var.create_argocd ? 1 : 0
  zone_id = data.aws_route53_zone.route53_zone.id
  name    = var.argocd_hostname
  type    = "CNAME"
  ttl     = 60
  records = [data.kubernetes_ingress_v1.aws_argocd_elb[0].status.0.load_balancer.0.ingress.0.hostname]
  depends_on = [
    kubernetes_ingress_v1.argocd_elb_ingress,
  ]
}

