<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_argocd"></a> [argocd](#requirement\_argocd) | 7.6.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.96.0 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | >= 1.15.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.30.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.96.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | >= 1.15.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.30.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |
| <a name="provider_time"></a> [time](#provider\_time) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_argocd_acm"></a> [argocd\_acm](#module\_argocd\_acm) | terraform-aws-modules/acm/aws | 5.1.1 |
| <a name="module_argocd_elb_sg"></a> [argocd\_elb\_sg](#module\_argocd\_elb\_sg) | terraform-aws-modules/security-group/aws | 5.3.0 |
| <a name="module_log_group"></a> [log\_group](#module\_log\_group) | terraform-aws-modules/cloudwatch/aws//modules/log-group | ~> 3.0 |
| <a name="module_wafv2"></a> [wafv2](#module\_wafv2) | aws-ss/wafv2/aws | 3.8.1 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.amazon_eks_velero_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.eso](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.velero_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.eso_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.velero_irsa_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_route53_record.argocd_cname_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_ssm_parameter.argo_admin_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [helm_release.argocd](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.argocd_nginx_ingress](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.aws_elb_controller](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.external_secrets](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.metrics_server](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.velero](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubectl_manifest.argocd_upstream_projects](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.aws_clustersecretstore](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.capi_cluster_catalogs_repo_es_github](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.capi_cluster_catalogs_repo_es_gitlab](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.kube_cm_argocd_application](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubernetes_ingress_v1.argocd_elb_ingress](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress_v1) | resource |
| [kubernetes_service_account.es_operator_sa](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [random_password.random_argo_admin_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [time_static.current_time](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/static) | resource |
| [time_static.one_hour_ahead](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/static) | resource |
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_iam_openid_connect_provider.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_openid_connect_provider) | data source |
| [aws_iam_policy_document.eso_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.velero_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_route53_zone.route53_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_subnets.public_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |
| [kubernetes_ingress_v1.aws_argocd_elb](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/ingress_v1) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addition_tags"></a> [addition\_tags](#input\_addition\_tags) | n/a | `map(any)` | `{}` | no |
| <a name="input_argocd_admin_password_length"></a> [argocd\_admin\_password\_length](#input\_argocd\_admin\_password\_length) | n/a | `number` | `32` | no |
| <a name="input_argocd_admin_secret_params_name"></a> [argocd\_admin\_secret\_params\_name](#input\_argocd\_admin\_secret\_params\_name) | n/a | `string` | `""` | no |
| <a name="input_argocd_alb_ingress_parameter"></a> [argocd\_alb\_ingress\_parameter](#input\_argocd\_alb\_ingress\_parameter) | n/a | `map(any)` | `{}` | no |
| <a name="input_argocd_elb_waf_acl_enabled_logging_configuration"></a> [argocd\_elb\_waf\_acl\_enabled\_logging\_configuration](#input\_argocd\_elb\_waf\_acl\_enabled\_logging\_configuration) | n/a | `bool` | `false` | no |
| <a name="input_argocd_elb_waf_acl_log_destination_configs_arn"></a> [argocd\_elb\_waf\_acl\_log\_destination\_configs\_arn](#input\_argocd\_elb\_waf\_acl\_log\_destination\_configs\_arn) | n/a | `string` | `""` | no |
| <a name="input_argocd_elb_waf_acl_resource_arn"></a> [argocd\_elb\_waf\_acl\_resource\_arn](#input\_argocd\_elb\_waf\_acl\_resource\_arn) | n/a | `list(any)` | `[]` | no |
| <a name="input_argocd_elb_waf_acl_visibility_config"></a> [argocd\_elb\_waf\_acl\_visibility\_config](#input\_argocd\_elb\_waf\_acl\_visibility\_config) | n/a | `map` | `{}` | no |
| <a name="input_argocd_elb_waf_default_action"></a> [argocd\_elb\_waf\_default\_action](#input\_argocd\_elb\_waf\_default\_action) | n/a | `string` | `"allow"` | no |
| <a name="input_argocd_elb_waf_name"></a> [argocd\_elb\_waf\_name](#input\_argocd\_elb\_waf\_name) | n/a | `string` | `""` | no |
| <a name="input_argocd_elb_waf_rules"></a> [argocd\_elb\_waf\_rules](#input\_argocd\_elb\_waf\_rules) | n/a | `list` | `[]` | no |
| <a name="input_argocd_elb_waf_scope"></a> [argocd\_elb\_waf\_scope](#input\_argocd\_elb\_waf\_scope) | n/a | `string` | `"REGIONAL"` | no |
| <a name="input_argocd_hostname"></a> [argocd\_hostname](#input\_argocd\_hostname) | n/a | `string` | `""` | no |
| <a name="input_argocd_ingress_classname"></a> [argocd\_ingress\_classname](#input\_argocd\_ingress\_classname) | n/a | `string` | `""` | no |
| <a name="input_argocd_projects_roles"></a> [argocd\_projects\_roles](#input\_argocd\_projects\_roles) | n/a | `list` | `[]` | no |
| <a name="input_argocd_repo_creds_github"></a> [argocd\_repo\_creds\_github](#input\_argocd\_repo\_creds\_github) | n/a | `map` | `{}` | no |
| <a name="input_argocd_repo_creds_gitlab"></a> [argocd\_repo\_creds\_gitlab](#input\_argocd\_repo\_creds\_gitlab) | n/a | `map` | `{}` | no |
| <a name="input_argocd_upstream_application_config"></a> [argocd\_upstream\_application\_config](#input\_argocd\_upstream\_application\_config) | n/a | `map` | `{}` | no |
| <a name="input_argocd_upstream_projects_roles"></a> [argocd\_upstream\_projects\_roles](#input\_argocd\_upstream\_projects\_roles) | n/a | `list` | `[]` | no |
| <a name="input_assume_role_str"></a> [assume\_role\_str](#input\_assume\_role\_str) | AWS assume-role arn - useful for runner contexts and shared system(s) | `string` | `""` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster | `string` | `"cluster-manager"` | no |
| <a name="input_create"></a> [create](#input\_create) | Controls if resources should be created (affects nearly all resources) | `bool` | `true` | no |
| <a name="input_create_argocd"></a> [create\_argocd](#input\_create\_argocd) | ############################################################################### ## ArgoCD ############################################################################### | `bool` | `false` | no |
| <a name="input_create_aws_elb_controller"></a> [create\_aws\_elb\_controller](#input\_create\_aws\_elb\_controller) | n/a | `bool` | `false` | no |
| <a name="input_create_external_secrets"></a> [create\_external\_secrets](#input\_create\_external\_secrets) | n/a | `bool` | `false` | no |
| <a name="input_create_metrics_server"></a> [create\_metrics\_server](#input\_create\_metrics\_server) | n/a | `bool` | `false` | no |
| <a name="input_create_velero_controller"></a> [create\_velero\_controller](#input\_create\_velero\_controller) | n/a | `bool` | `false` | no |
| <a name="input_custom_domain"></a> [custom\_domain](#input\_custom\_domain) | n/a | `string` | `"kubesources.com"` | no |
| <a name="input_default_argocd_alb_ingress_parameter"></a> [default\_argocd\_alb\_ingress\_parameter](#input\_default\_argocd\_alb\_ingress\_parameter) | n/a | `map(any)` | <pre>{<br/>  "argocd_alb_ingress_certificate_arn": "argocd_alb_ingress_certificate_arn",<br/>  "argocd_alb_ingress_healthcheck_path": "argocd_alb_ingress_healthcheck_path",<br/>  "argocd_alb_ingress_load_balancer_attributes": "argocd_alb_ingress_load_balancer_attributes",<br/>  "argocd_alb_ingress_name": "argocd_alb_ingress_name",<br/>  "argocd_alb_ingress_namespace": "argocd_alb_ingress_namespace",<br/>  "argocd_alb_ingress_scheme": "argocd_alb_ingress_scheme",<br/>  "argocd_alb_ingress_security_groups": "argocd_alb_ingress_security_groups",<br/>  "argocd_alb_ingress_ssl_policy": "argocd_alb_ingress_ssl_policy",<br/>  "argocd_alb_ingress_success_codes": "argocd_alb_ingress_success_codes",<br/>  "argocd_alb_ingress_target_type": "argocd_alb_ingress_target_type",<br/>  "argocd_alb_ingress_waf_arn": "argocd_alb_ingress_waf_arn"<br/>}</pre> | no |
| <a name="input_default_argocd_ingress_classname"></a> [default\_argocd\_ingress\_classname](#input\_default\_argocd\_ingress\_classname) | n/a | `string` | `"argocd"` | no |
| <a name="input_default_argocd_upstream_application_config_key"></a> [default\_argocd\_upstream\_application\_config\_key](#input\_default\_argocd\_upstream\_application\_config\_key) | n/a | `map` | <pre>{<br/>  "destination_namespace": "destination_namespace",<br/>  "destination_server": "destination_server",<br/>  "ext_var_key": "ext_var_key",<br/>  "ext_var_value": "ext_var_value",<br/>  "project": "project",<br/>  "repo_url": "repo_url",<br/>  "target_revision": "target_revision",<br/>  "version_path": "version_path"<br/>}</pre> | no |
| <a name="input_default_aws_elb_controller_ingress_class"></a> [default\_aws\_elb\_controller\_ingress\_class](#input\_default\_aws\_elb\_controller\_ingress\_class) | n/a | `string` | `"alb"` | no |
| <a name="input_default_helm_release_set_parameter"></a> [default\_helm\_release\_set\_parameter](#input\_default\_helm\_release\_set\_parameter) | n/a | `list` | <pre>[<br/>  {<br/>    "name": "tolerations[0].key",<br/>    "value": "node-role.kubernetes.io/control-plane"<br/>  },<br/>  {<br/>    "name": "tolerations[0].value",<br/>    "value": "true"<br/>  },<br/>  {<br/>    "name": "tolerations[0].operator",<br/>    "value": "Equal"<br/>  },<br/>  {<br/>    "name": "tolerations[0].effect",<br/>    "value": "NoSchedule"<br/>  }<br/>]</pre> | no |
| <a name="input_default_helm_repo_parameter"></a> [default\_helm\_repo\_parameter](#input\_default\_helm\_repo\_parameter) | n/a | `map` | <pre>{<br/>  "helm_repo_chart": "helm_repo_chart",<br/>  "helm_repo_name": "helm_repo_name",<br/>  "helm_repo_namespace": "helm_repo_namespace",<br/>  "helm_repo_timeout": "helm_repo_timeout",<br/>  "helm_repo_url": "helm_repo_url",<br/>  "helm_repo_version": "helm_repo_version"<br/>}</pre> | no |
| <a name="input_helm_release_argocd_ingress_nginx_parameter"></a> [helm\_release\_argocd\_ingress\_nginx\_parameter](#input\_helm\_release\_argocd\_ingress\_nginx\_parameter) | n/a | `map(any)` | `{}` | no |
| <a name="input_helm_release_argocd_parameter"></a> [helm\_release\_argocd\_parameter](#input\_helm\_release\_argocd\_parameter) | n/a | `map(any)` | `{}` | no |
| <a name="input_helm_release_aws_elb_controller_parameter"></a> [helm\_release\_aws\_elb\_controller\_parameter](#input\_helm\_release\_aws\_elb\_controller\_parameter) | n/a | `map(any)` | `{}` | no |
| <a name="input_helm_release_external_secrets_parameter"></a> [helm\_release\_external\_secrets\_parameter](#input\_helm\_release\_external\_secrets\_parameter) | n/a | `map(any)` | `{}` | no |
| <a name="input_helm_release_external_secrets_serviceaccount_name"></a> [helm\_release\_external\_secrets\_serviceaccount\_name](#input\_helm\_release\_external\_secrets\_serviceaccount\_name) | n/a | `string` | `"es-irsa"` | no |
| <a name="input_helm_release_metrics_server_parameter"></a> [helm\_release\_metrics\_server\_parameter](#input\_helm\_release\_metrics\_server\_parameter) | n/a | `map(any)` | `{}` | no |
| <a name="input_helm_release_velero_parameter"></a> [helm\_release\_velero\_parameter](#input\_helm\_release\_velero\_parameter) | n/a | `map(any)` | `{}` | no |
| <a name="input_helm_release_velero_serviceaccount_name"></a> [helm\_release\_velero\_serviceaccount\_name](#input\_helm\_release\_velero\_serviceaccount\_name) | n/a | `string` | `"velero-irsa"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS default region | `string` | `"us-east-1"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | `{}` | no |
| <a name="input_vpc_prefix"></a> [vpc\_prefix](#input\_vpc\_prefix) | n/a | `string` | `""` | no |
| <a name="input_vpc_public_subnets_name_prefix"></a> [vpc\_public\_subnets\_name\_prefix](#input\_vpc\_public\_subnets\_name\_prefix) | n/a | `string` | `"upstream_vpc-public"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->