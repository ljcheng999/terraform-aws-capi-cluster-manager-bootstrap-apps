

locals {
  ingress_load_balancer_tags = {
    "service.k8s.aws/resource" = "LoadBalancer"
    "service.k8s.aws/stack"    = "${lookup(var.helm_release_argocd_ingress_nginx_parameter, var.default_helm_repo_parameter.helm_repo_namespace, "nginx")}/${lookup(var.argocd_alb_ingress_parameter, var.default_argocd_alb_ingress_parameter.argocd_alb_ingress_name, "${var.cluster_name}-argocd-ingress-nginx-controller")}"
    "elbv2.k8s.aws/cluster"    = var.cluster_name
  }

  # aws_elb_name_parts = split("-", split(".", data.kubernetes_service.aws_argocd_elb[0].status.0.load_balancer.0.ingress.0.hostname))

}
