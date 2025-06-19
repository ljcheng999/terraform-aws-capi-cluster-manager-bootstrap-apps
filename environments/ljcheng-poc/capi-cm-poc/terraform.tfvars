
addition_tags = {}

create       = true
cluster_name = "capi-cm-poc"
custom_domain = "kubesources.com"


#########################################################################
### AWS ELB
#########################################################################
create_aws_elb_controller = true
helm_release_aws_elb_controller_parameter = {
  helm_repo_chart     = "aws-load-balancer-controller"
  helm_repo_namespace = "nginx"
  helm_repo_version   = "1.13.2"
}

#########################################################################
### External Secrets
#########################################################################
create_external_secrets = true
helm_release_external_secrets_parameter = {
  helm_repo_chart     = "external-secrets"
  helm_repo_version   = "0.17.0"
}

#########################################################################
### Metrics server
#########################################################################
create_metric_server = true
helm_release_metric_server_parameter = {
  helm_repo_chart     = "metrics-server"
  helm_repo_version   = "3.12.2"
}

#########################################################################
### Velero
#########################################################################
create_velero_controller = true
helm_release_velero_parameter = {
  helm_repo_chart     = "velero"
  helm_repo_version   = "10.0.3"
  cloud_provider = "aws"  
}






# #########################################################################
# ### ArgoCD
# #########################################################################
# ### Ingress and ArgoCD work together
create_argocd = false
helm_release_argocd_ingress_nginx_parameter = {
  helm_repo_chart     = "ingress-nginx"
  helm_repo_version   = "4.12.2"
}
helm_release_argocd_parameter = {
  helm_repo_chart     = "argo-cd"
  helm_repo_namespace = "argocd"
  helm_repo_version   = "8.0.15"
}
argocd_alb_ingress_parameter = {
  # argocd_alb_ingress_name = ""
  argocd_alb_ingress_namespace = "nginx"
  argocd_alb_ingress_healthcheck_path = "/healthz"
  argocd_alb_ingress_load_balancer_attributes = "idle_timeout.timeout_seconds=600"
  argocd_alb_ingress_scheme = "internet-facing"
  argocd_alb_ingress_security_groups = ""
  argocd_alb_ingress_ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  argocd_alb_ingress_success_codes = "200"
  argocd_alb_ingress_target_type = "instance"
  argocd_alb_ingress_waf_arn = ""
}

# argocd_elb_waf_name = "argocd-waf-acl"
argocd_elb_waf_scope = "REGIONAL"
argocd_elb_waf_default_action = "allow"
# argocd_elb_waf_rules = []
argocd_elb_waf_acl_resource_arn = []
argocd_elb_waf_acl_visibility_config = {
  cloudwatch_metrics_enabled = true
  sampled_requests_enabled = true
}
argocd_elb_waf_acl_enabled_logging_configuration = false

argocd_upstream_projects_roles = [
  {
    name = "cluster-manager" #require to have cluster-manager
    # namespace = "test"
  },
  {
    name = "aws-533267295140-dm-digitalmarketing-dev"
  }
]

argocd_upstream_application_config = {
  version_path          = "capi-v5"
  ext_var_value         = "bfe"
}

