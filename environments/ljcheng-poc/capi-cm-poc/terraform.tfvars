
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


create_velero_controller = true
helm_release_velero_parameter = {
  helm_repo_namespace = "velero"
  helm_repo_url = "https://vmware-tanzu.github.io/helm-charts"
  helm_repo_name = "velero"
  helm_repo_crd = null
  helm_repo_timeout = 4000
  helm_repo_version = "9.1.0"
  cloud_provider = "aws"
  cloud_bucket  = "velero-ljcheng-cluster-backups"
  cloud_bucket_folder_name = "core-kubesources-cluster-backups"
  cloud_region  = "us-east-1"
  cloud_bucket_prefix = "capi-cm-poc"
}
helm_release_velero_set_parameter = [
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


route53_zone_id = "Z02763451I8QENECRLHM9"