
resource "helm_release" "external_secrets" {
  count            = local.create && local.create_external_secrets ? 1 : 0
  create_namespace = local.create_external_secrets_namespace

  chart            = lookup(local.helm_release_external_secrets_parameter, var.default_helm_repo_parameter.helm_repo_name, "external-secrets")
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

data "aws_iam_policy_document" "eso_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = [
        data.aws_iam_openid_connect_provider.this[0].arn
      ]
    }
    condition {
      test     = "StringEquals"
      # variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
      variable = "${replace(data.aws_iam_openid_connect_provider.this[0].url, "https://", "")}:sub"
      # values   = ["system:serviceaccount:${kubernetes_namespace.eso.metadata[0].name}:external-secrets"]
      values   = ["system:serviceaccount:*:external-secrets"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "eso_policy_attachment" {
  role       = aws_iam_role.eso.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_iam_role" "eso" {
  name               = "eks-external-secrets-operator"
  assume_role_policy = data.aws_iam_policy_document.eso_assume_role.json
}

resource "kubernetes_service_account" "external_secrets_operator" {
  metadata {
    name      = "external-secrets-operator"
    namespace = "external-secrets"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.eso.arn
    }
  }
}



resource "kubernetes_manifest" "aws_clustersecretstore" {
  
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ClusterSecretStore"
    metadata = {
      name      = "${var.cluster_name}-cluster-secret-store"
    }
    spec = {
      provider = {
        aws = {
          service = lookup(local.helm_release_external_secrets_parameter, "service", "SecretsManager")
          role    = aws_iam_role.eso.arn
          region  = lookup(local.helm_release_external_secrets_parameter, "region", "us-east-1")
        }
      }
    }
  }

  depends_on = [
    helm_release.external_secrets
  ]
}

# resource "kubernetes_manifest" "gitlab_argocd_bfe_core_systems_capi_secret_store" {
#   computed_fields = [
#     "metadata.labels",
#     "metadata.annotations",
#     "metadata.finalizers"
#   ]

#   manifest = {
#     apiVersion = "external-secrets.io/v1beta1"
#     kind       = "SecretStore"

#     metadata = {
#       namespace   = "argocd"
#       name        = "gitlab-bfe-core-systems-capi-secret-store-${local.provision_environment}"
#       finalizers  = var.cascade_delete ? ["resources-finalizer.argocd.argoproj.io"] : []
#     }


#     spec = {
#       #optional
#       # controller = dev

#       provider = {
#         aws = {
#           service = var.gitlab_argocd_bfe_core_systems_capi_secret_store_service
#           role = var.gitlab_argocd_bfe_core_systems_capi_secret_store_role_arn
#           region = var.region
#         }
#       }
#     }
#   }

#   depends_on = [
#     helm_release.external_secrets,
#   ]
# }

# resource "kubernetes_manifest" "gitlab_argocd_bfe_core_systems_capi_external_secret" {
#   computed_fields = [
#     "metadata.labels",
#     "metadata.annotations",
#     "metadata.finalizers"
#   ]

#   manifest = {
#     apiVersion = "external-secrets.io/v1beta1"
#     kind       = "ExternalSecret"

#     metadata = {
#       namespace   = "argocd"
#       name        = "gitlab-bfe-core-systems-capi-external-secret-${local.provision_environment}"
#       finalizers  = []
#     }

#     spec = {

#       secretStoreRef = {
#         name = kubernetes_manifest.gitlab_argocd_bfe_core_systems_capi_secret_store.manifest.metadata.name
#         kind = "SecretStore"
#       }

#       refreshInterval = "1h"

#       target = {
#         name = "gitlab-capi-core-systems-https-repo-${local.provision_environment}"
#         creationPolicy = "Owner"
#         deletionPolicy = "Delete"
        
#         template = {
#           metadata = {
#             labels = {
#               "argocd.argoproj.io/secret-type" = "repo-creds"
#             }
#           }
#         }
#       }


#       data = [
#         {
#           secretKey = "url"
#           remoteRef = {
#             key = "cluster-manager/${local.prefix}-${local.provision_environment}/gitlab/digitalmarketing/infra/capi-core-systems/capi/creds",
#             property = "url"
#           }
#         },
#         {
#           secretKey = "username"
#           remoteRef = {
#             key = "cluster-manager/${local.prefix}-${local.provision_environment}/gitlab/digitalmarketing/infra/capi-core-systems/capi/creds",
#             property = "username"
#           }
#         },
#         {
#           secretKey = "password"
#           remoteRef = {
#             key = "cluster-manager/${local.prefix}-${local.provision_environment}/gitlab/digitalmarketing/infra/capi-core-systems/capi/creds",
#             property = "password"
#           }
#         }
#       ]
#     }
#   }

#   depends_on = [
#     helm_release.external_secrets,
#   ]
# }