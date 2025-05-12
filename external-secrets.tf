
resource "helm_release" "external_secrets" {
  count            = local.create && local.create_external_secrets ? 1 : 0
  create_namespace = local.create_external_secrets_namespace

  chart            = lookup(local.helm_release_external_secrets_parameter, var.default_helm_repo_parameter.helm_repo_chart, "external-secrets")
  name             = lookup(local.helm_release_external_secrets_parameter, var.default_helm_repo_parameter.helm_repo_name, "external-secrets")
  namespace        = lookup(local.helm_release_external_secrets_parameter, var.default_helm_repo_parameter.helm_repo_namespace, "external-secrets")
  repository       = lookup(local.helm_release_external_secrets_parameter, var.default_helm_repo_parameter.helm_repo_url, "https://charts.external-secrets.io")
  version          = lookup(local.helm_release_external_secrets_parameter, var.default_helm_repo_parameter.helm_repo_version, "0.16.1")
  timeout          = lookup(local.helm_release_external_secrets_parameter, var.default_helm_repo_parameter.helm_repo_timeout, 4000)

  wait             = true
  wait_for_jobs    = true
  max_history      = 3
  
  dynamic "set" {
   for_each = length(local.helm_release_external_secrets_set_parameter) > 0 ? local.helm_release_external_secrets_set_parameter : []
    content {
      name = set.value.name
      value = set.value.value
    }
  }

  # values = [
  #   "${file("${path.module}/templates/helm/external-secrets-values.yaml")}",
  # ]
}

resource "aws_iam_role_policy_attachment" "eso_policy_attachment" {
  role       = aws_iam_role.eso.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_iam_role" "eso" {
  name               = "${var.cluster_name}-eks-external-secrets-operator"
  assume_role_policy = data.aws_iam_policy_document.eso_assume_role[0].json
}

resource "kubernetes_service_account" "es_operator_sa" {
  metadata {
    name      = var.helm_release_external_secrets_serviceaccount_name
    namespace = "${lookup(local.helm_release_external_secrets_parameter, var.default_helm_repo_parameter.helm_repo_namespace, "external-secrets")}"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.eso.arn
    }
  }

  depends_on = [
    helm_release.external_secrets
  ]
}


resource "kubernetes_manifest" "aws_clustersecretstore" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ClusterSecretStore"
    metadata = {
      name        = "${var.cluster_name}-cluster-secret-store"
    }
    spec = {
      provider = {
        aws = {
          auth = {
            jwt = {
              serviceAccountRef = {
                name = "${kubernetes_service_account.es_operator_sa.metadata[0].name}"
                namespace = lookup(local.helm_release_external_secrets_parameter, var.default_helm_repo_parameter.helm_repo_namespace, "external-secrets")
              }
            }
          }
          service = lookup(local.helm_release_external_secrets_parameter, "service", "SecretsManager")
          region  = lookup(local.helm_release_external_secrets_parameter, "region", "us-east-1")
        }
      }
    }
  }
  depends_on = [
    helm_release.external_secrets
  ]
}

