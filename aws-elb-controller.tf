###############################################
#     AWS ELB Controller Helm Chart
###############################################
resource "helm_release" "aws_elb_controller" {
  count            = var.create && var.create_aws_elb_controller ? 1 : 0
  create_namespace = true

  chart      = lookup(var.helm_release_aws_elb_controller_parameter, var.default_helm_repo_parameter.helm_repo_chart, "aws-load-balancer-controller")
  name       = lookup(var.helm_release_aws_elb_controller_parameter, var.default_helm_repo_parameter.helm_repo_name, "aws-load-balancer-controller")
  namespace  = lookup(var.helm_release_aws_elb_controller_parameter, var.default_helm_repo_parameter.helm_repo_namespace, "nginx")
  repository = lookup(var.helm_release_aws_elb_controller_parameter, var.default_helm_repo_parameter.helm_repo_url, "https://aws.github.io/eks-charts")
  version    = lookup(var.helm_release_aws_elb_controller_parameter, var.default_helm_repo_parameter.helm_repo_version, "1.13.2")
  timeout    = lookup(var.helm_release_aws_elb_controller_parameter, var.default_helm_repo_parameter.helm_repo_timeout, 4000)

  wait          = true
  wait_for_jobs = true
  max_history   = 3

  values = [templatefile("${path.module}/templates/helm/aws-elb-controller-values.yaml", {
    cluster_name     = "${var.cluster_name}",
    ingressClass     = "${var.default_aws_elb_controller_ingress_class}",
    toleration_key   = "node.${var.custom_domain}/role",
    toleration_value = "system",
  })]
}
