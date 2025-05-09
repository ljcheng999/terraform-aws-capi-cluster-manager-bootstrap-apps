data "aws_eks_cluster" "this" {
  count = local.create ? 1 : 0
  name  = var.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  count = local.create ? 1 : 0
  name  = var.cluster_name
  depends_on = [
    data.aws_eks_cluster.this
  ]
}






# data "aws_route_table" "example" {
#   vpc_id = "vpc-123456" # Replace with your VPC ID
#   tags = {
#     Name = "routetable-name"
#   }
# }

# # This data will contain all of your subnets within the given VPC
# data "aws_subnets" "all" {
#   filter {
#     name   = "vpc-id"
#     values = [data.aws_route_table.example.vpc_id]
#   }
# }

# # This data will contain all subnets associated with the given route table
# data "aws_subnet" "associated" {
#   for_each = toset([for assoc in data.aws_route_table.example.associations : assoc.subnet_id])

#   id = each.key
# }

# # Use the setsubtract function to find unassociated subnets
# locals {
#   all_subnet_ids = [for subnet in data.aws_subnets.all.ids : subnet]
#   associated_subnet_ids = [for subnet in data.aws_route_table.example.associations : subnet.subnet_id]
#   unassociated_subnet_ids = setsubtract(local.all_subnet_ids, local.associated_subnet_ids)
# }








# # Find a certificate issued by (not imported into) ACM
# data "aws_acm_certificate" "argo_cd_amazon_issued" {
#   count       = var.create_argocd_cert ? 1 : 0
#   domain      = local.final_acm_domain
#   types       = ["AMAZON_ISSUED"]
#   most_recent = true

#   depends_on = [ 
#     aws_acm_certificate_validation.argo.0
#   ]
# }

# data "aws_acm_certificate" "kube_dashboard_amazon_issued" {
#   count       = var.create_kube_dashboard_cert ? 1 : 0
#   domain      = local.final_kube_dashboard_acm_domain
#   types       = ["AMAZON_ISSUED"]
#   most_recent = true

#   depends_on = [ 
#     aws_acm_certificate_validation.kube_dashboard.0
#   ]
# }