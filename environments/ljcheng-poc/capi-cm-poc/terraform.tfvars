
addition_tags = {}

create       = true
cluster_name = "capi-cm-poc"

### ArgoCD
create_argocd = false
create_argocd_cert = false
create_wildcard_argocd_cert = false
helm_release_argocd_helm_chart_version = "8.0.0"




### AWS ELB
create_aws_elb_controller = true
helm_release_aws_elb_controller_parameter = {
  helm_repo_namespace = "nginx"
  helm_repo_url = "https://aws.github.io/eks-charts"
  helm_repo_name = "aws-load-balancer-controller"
  helm_repo_version = "1.13.0"
  helm_repo_crd = null
}
helm_release_aws_elb_controller_set_parameter = [
  {
    name = "clusterName"
    value = "capi-cm-poc"
  },
  {
    name  = "tolerations[0].key"
    value = "node.kubesources.com/role"
  },
  {
    name  = "tolerations[0].value"
    value = "system"
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

# node-role.kubernetes.io/control-plane=true:NoSchedule

create_external_secrets = true
helm_release_external_secrets_parameter = {
  helm_repo_namespace = "external-secrets"
  helm_repo_url = "https://charts.external-secrets.io"
  helm_repo_name = "external-secrets"
  helm_repo_version = "0.16.2"
  helm_repo_crd = null
}
helm_release_external_secrets_set_parameter = [
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




route53_zone_id = "Z02763451I8QENECRLHM9"