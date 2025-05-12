###############################################
#     AWS ELB Controller Helm Chart
###############################################
resource "helm_release" "aws_elb_controller" {
  count            = local.create && local.create_aws_elb_controller ? 1 : 0
  create_namespace = local.create_aws_elb_controller_namespace

  chart            = lookup(local.helm_release_aws_elb_controller_parameter, var.default_helm_repo_parameter.helm_repo_chart, "aws-load-balancer-controller")
  name             = lookup(local.helm_release_aws_elb_controller_parameter, var.default_helm_repo_parameter.helm_repo_name, "aws-load-balancer-controller")
  namespace        = lookup(local.helm_release_aws_elb_controller_parameter, var.default_helm_repo_parameter.helm_repo_namespace, "kube-system")
  repository       = lookup(local.helm_release_aws_elb_controller_parameter, var.default_helm_repo_parameter.helm_repo_url, "https://aws.github.io/eks-charts")
  version          = lookup(local.helm_release_aws_elb_controller_parameter, var.default_helm_repo_parameter.helm_repo_version, "1.13.0")
  timeout          = lookup(local.helm_release_aws_elb_controller_parameter, var.default_helm_repo_parameter.helm_repo_timeout, 4000)

  wait             = true
  wait_for_jobs    = true
  max_history      = 3

  dynamic "set" {
    for_each = length(var.helm_release_aws_elb_controller_set_parameter) > 0 ? var.helm_release_aws_elb_controller_set_parameter : []
    content {
      name = set.value.name
      value = set.value.value
    }
  }

    # values = [
  #   templatefile("${path.module}/templates/helm/aws-elb-controller-values.yaml", {
  #     cluster_name="${local.cluster_name}"
  #   })
  # ]
}
