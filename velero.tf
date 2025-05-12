
resource "helm_release" "velero" {
  count            = local.create && local.create_velero_controller ? 1 : 0
  create_namespace = local.create_velero_namespace

  chart            = lookup(local.helm_release_velero_parameter, var.default_helm_repo_parameter.helm_repo_chart, "velero")
  name             = lookup(local.helm_release_velero_parameter, var.default_helm_repo_parameter.helm_repo_name, "velero")
  namespace        = lookup(local.helm_release_velero_parameter, var.default_helm_repo_parameter.helm_repo_namespace, "velero")
  repository       = lookup(local.helm_release_velero_parameter, var.default_helm_repo_parameter.helm_repo_url, "https://vmware-tanzu.github.io/helm-charts/")
  version          = lookup(local.helm_release_velero_parameter, var.default_helm_repo_parameter.helm_repo_version, "9.1.2")
  timeout          = lookup(local.helm_release_velero_parameter, var.default_helm_repo_parameter.helm_repo_timeout, 4000)

  wait             = true
  wait_for_jobs    = true
  max_history      = 3
  
  dynamic "set" {
   for_each = length(local.helm_release_velero_set_parameter) > 0 ? local.helm_release_velero_set_parameter : []
    content {
      name = set.value.name
      value = set.value.value
    }
  }

  values = [templatefile("${path.module}/templates/helm/velero.yaml", {
    cloud_provider            = lookup(local.helm_release_velero_parameter, "cloud_provider", "aws")
    cloud_bucket              = lookup(local.helm_release_velero_parameter, "cloud_bucket", "ljc-cluster-backups")
    cloud_bucket_folder_name  = lookup(local.helm_release_velero_parameter, "cloud_bucket_folder_name", "core-kubesources-cluster-backups")
    cloud_region              = lookup(local.helm_release_velero_parameter, "cloud_region", "us-east-1")
    cloud_bucket_prefix       = var.cluster_name
  })]
}

resource "aws_iam_policy" "amazon_eks_velero_policy" {
  name        = "velero-${var.cluster_name}-policy"
  description = "Policy for ${var.cluster_name} CAPI Cluster Velero policy"
  policy      = file("${path.module}/templates/aws/velero-policy.json")

  tags = merge(
    {
      "Name": "velero-${var.cluster_name}-policy"
    },
    var.tags,
  )
}

resource "aws_iam_role" "velero_role" {
  name               = "${var.cluster_name}-eks-velero-operator"
  assume_role_policy = data.aws_iam_policy_document.velero_assume_role[0].json
}

resource "kubernetes_service_account" "velero_operator_sa" {
  metadata {
    name      = var.helm_release_velero_serviceaccount_name
    namespace = "${lookup(local.helm_release_velero_parameter, var.default_helm_repo_parameter.helm_repo_namespace, "velero")}"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.velero_role.arn
    }
  }

  depends_on = [
    helm_release.velero
  ]
}










# resource "kubernetes_manifest" "aws_velero_external_secret" {
#   manifest = {
#     apiVersion = "external-secrets.io/v1beta1"
#     kind       = "ExternalSecret"

#     metadata = {
#       namespace   = lookup(local.helm_release_velero_parameter, var.default_helm_repo_parameter.helm_repo_namespace, "velero")
#       name        = "${var.cluster_name}-velero-es"
#       finalizers  = []
#     }

#     spec = {
#       secretStoreRef = {
#         name = kubernetes_manifest.aws_clustersecretstore.manifest.metadata.name
#         kind = "ClusterSecretStore"
#       }

#       refreshInterval = "1h"

#       target = {
#         name           = "${var.cluster_name}-velero-es"
#         creationPolicy = "Owner"
#         deletionPolicy = "Retain"
        
#         template = {
#           # metadata = {
#           #   labels = {
#           #     "argocd.argoproj.io/secret-type" = "repo-creds"
#           #   }
#           # }
#         }

#         # template:
#         #   data:
#         #     cloud: |
#         #       [default]
#         #       aws_access_key_id = {{ .awsAccessKeyID | toString }}
#         #       aws_secret_access_key = {{ .awsSecretAccessKey | toString }}

#         #       [profile default]
#         #       region = {{ .awsRegion | toString }}
#         #   engineVersion: v1
#         #   mergePolicy: Replace
#         #   metadata: {}
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
# }