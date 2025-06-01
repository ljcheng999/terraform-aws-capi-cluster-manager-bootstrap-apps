
resource "helm_release" "external_secrets" {
  count            = var.create && var.create_external_secrets ? 1 : 0
  create_namespace = true

  chart      = lookup(var.helm_release_external_secrets_parameter, var.default_helm_repo_parameter.helm_repo_chart, "external-secrets")
  name       = lookup(var.helm_release_external_secrets_parameter, var.default_helm_repo_parameter.helm_repo_name, "external-secrets")
  namespace  = lookup(var.helm_release_external_secrets_parameter, var.default_helm_repo_parameter.helm_repo_namespace, "external-secrets")
  repository = lookup(var.helm_release_external_secrets_parameter, var.default_helm_repo_parameter.helm_repo_url, "https://charts.external-secrets.io")
  version    = lookup(var.helm_release_external_secrets_parameter, var.default_helm_repo_parameter.helm_repo_version, "0.17.0")
  timeout    = lookup(var.helm_release_external_secrets_parameter, var.default_helm_repo_parameter.helm_repo_timeout, 4000)

  wait          = true
  wait_for_jobs = true
  max_history   = 3

  values = [templatefile("${path.module}/templates/helm/external-secrets-values.yaml", {
    toleration_key   = "node.${var.custom_domain}/role",
    toleration_value = "system",
  })]
  depends_on = [
    helm_release.aws_elb_controller
  ]
}

resource "aws_iam_role_policy_attachment" "eso_policy_attachment" {
  count      = var.create && var.create_external_secrets ? 1 : 0
  role       = aws_iam_role.eso[0].name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_iam_role" "eso" {
  count              = var.create && var.create_external_secrets ? 1 : 0
  name               = "${var.cluster_name}-eks-external-secrets-operator"
  assume_role_policy = data.aws_iam_policy_document.eso_assume_role[0].json
}

resource "kubernetes_service_account" "es_operator_sa" {
  count = var.create && var.create_external_secrets ? 1 : 0
  metadata {
    name      = var.helm_release_external_secrets_serviceaccount_name
    namespace = lookup(var.helm_release_external_secrets_parameter, var.default_helm_repo_parameter.helm_repo_namespace, "external-secrets")
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.eso[0].arn
    }
  }

  depends_on = [
    helm_release.external_secrets
  ]
}

resource "kubectl_manifest" "aws_clustersecretstore" {
  count     = var.create && var.create_external_secrets ? 1 : 0
  yaml_body = <<-EOF
    apiVersion: external-secrets.io/v1
    kind: ClusterSecretStore
    metadata:
      name: "${var.cluster_name}-cluster-secret-store"
    spec:
      provider:
        aws:
          auth:
            jwt:
              serviceAccountRef:
                name: "${kubernetes_service_account.es_operator_sa[0].metadata[0].name}"
                namespace: ${lookup(var.helm_release_external_secrets_parameter, var.default_helm_repo_parameter.helm_repo_namespace, "external-secrets")}
          service: ${lookup(var.helm_release_external_secrets_parameter, "service", "SecretsManager")}
          region: ${lookup(var.helm_release_external_secrets_parameter, "region", "us-east-1")}
    EOF

  depends_on = [
    helm_release.external_secrets,
    aws_iam_role.eso,
    aws_iam_role_policy_attachment.eso_policy_attachment,
    kubernetes_service_account.es_operator_sa
  ]
}
