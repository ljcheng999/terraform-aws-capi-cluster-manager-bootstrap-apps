

# resource "kubectl_manifest" "aws_argocd_alb_ingress" {
#   count     = local.create && local.create_aws_elb_controller && var.create_argocd_alb_ingress ? 1 : 0
#   yaml_body = <<-EOF
#     apiVersion: networking.k8s.io/v1
#     kind: Ingress
#     metadata:
#       annotations:
#         alb.ingress.kubernetes.io/actions.ssl-redirect: {"Type": "redirect", "RedirectConfig": { "Protocol": "HTTPS", "Port":"443", "StatusCode": "HTTP_301"}}
#         alb.ingress.kubernetes.io/certificate-arn: "${lookup(local.aws_alb_ingress_parameter, var.default_aws_alb_ingress_parameter.aws_alb_ingress_certificate_arn, "")}"
#         alb.ingress.kubernetes.io/healthcheck-path: "${lookup(local.aws_alb_ingress_parameter, var.default_aws_alb_ingress_parameter.aws_alb_ingress_healthcheck_path, "/healthz")}"
#         alb.ingress.kubernetes.io/listen-ports: '[{"HTTP":80}, {"HTTPS":443}]'
#         alb.ingress.kubernetes.io/load-balancer-attributes: "${lookup(local.aws_alb_ingress_parameter, var.default_aws_alb_ingress_parameter.aws_alb_ingress_load_balancer_attributes, "idle_timeout.timeout_seconds=600")}"
#         alb.ingress.kubernetes.io/manage-backend-security-group-rules: 'true'
#         alb.ingress.kubernetes.io/scheme: "${lookup(local.aws_alb_ingress_parameter, var.default_aws_alb_ingress_parameter.aws_alb_ingress_scheme, "internet-facing")}"
#         alb.ingress.kubernetes.io/security-groups: ""
#         alb.ingress.kubernetes.io/ssl-policy: ELBSecurityPolicy-TLS13-1-2-2021-06
#         alb.ingress.kubernetes.io/subnets: ""
#         alb.ingress.kubernetes.io/success-codes: "${lookup(local.aws_alb_ingress_parameter, var.default_aws_alb_ingress_parameter.aws_alb_ingress_success_codes, "200")}"
#         alb.ingress.kubernetes.io/target-type: "${lookup(local.aws_alb_ingress_parameter, var.default_aws_alb_ingress_parameter.aws_alb_ingress_target_type, "instance")}"
#         alb.ingress.kubernetes.io/wafv2-acl-arn: ""
#       name: ${lookup(local.aws_alb_ingress_parameter, var.default_aws_alb_ingress_parameter.aws_alb_ingress_name, "${var.cluster_name}-alb-ingress")}
#       namespace: ${lookup(local.aws_alb_ingress_parameter, var.default_aws_alb_ingress_parameter.aws_alb_ingress_namespace, "kube-system")}
#     spec:
#       ingressClassName: ${lookup(local.aws_alb_ingress_parameter, var.default_aws_alb_ingress_parameter.aws_alb_ingress_classname, "alb")}
#       rules:
#       - http:
#           paths:
#             - backend:
#                 service:
#                   name: ssl-redirect
#                   port:
#                     name: use-annotation
#               path: /*
#               pathType: ImplementationSpecific
#             - backend:
#                 service:
#                   name: ingress-nginx-fw-controller
#                   port:
#                     number: 80
#               path: /*
#               pathType: ImplementationSpecific
#     EOF

#   depends_on = [
#     helm_release.aws_elb_controller
#   ]
# }

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
