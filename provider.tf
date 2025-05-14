terraform {
  required_providers {
    argocd = {
      source  = "argoproj-labs/argocd"
      version = "7.6.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.96.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.30.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.15.0"
    }
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this[0].endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this[0].certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this[0].token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.this[0].endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this[0].certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this[0].token
    # exec {
    #   api_version = "client.authentication.k8s.io/v1beta1"
    #   args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    #   command     = "aws"
    # }
  }
}

# provider "argocd" {
#   # insecure    = true
#   server_addr = "${local.argocd_endpoint}:443"
#   username    = "admin"
#   password    = aws_ssm_parameter.argo_admin_password.value

#   # kubernetes {
#   #   cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
#   #   host                   = data.aws_eks_cluster.this.endpoint
#   #   token                  = data.aws_eks_cluster_auth.this.token
#   #   # exec {
#   #   #   api_version = "client.authentication.k8s.io/v1beta1"
#   #   #   args        = ["eks", "get-token", "--cluster-name", "${local.prefix}-${local.provision_environment}"]
#   #   #   command     = "aws"
#   #   # }
#   # }

# }
