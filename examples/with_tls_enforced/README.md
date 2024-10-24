# End-to-End encryption Example
This example demonstrates creating a virtual node with `enforce_tls=true`. This will ensure that the traffic entering the AppMesh via virtual gateway will reach the backend using `TLS`

We need a `Private CA` to provision certificates. If an existing CA is not passed as inputs, the example with create one.

## Provider requirements
Make sure a `provider.tf` file is created with the below contents inside the `examples/with_tls_enforced` directory
```shell
provider "aws" {
  profile = "<profile_name>"
  region  = "<aws_region>"
}
# Used to create a random integer postfix for aws resources
provider "random" {}
```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 5.0.0 |
| <a name="module_private_ca"></a> [private\_ca](#module\_private\_ca) | terraform.registry.launch.nttdata.com/module_primitive/private_ca/aws | ~> 1.0 |
| <a name="module_namespace"></a> [namespace](#module\_namespace) | terraform.registry.launch.nttdata.com/module_primitive/private_dns_namespace/aws | ~> 1.0 |
| <a name="module_app_mesh"></a> [app\_mesh](#module\_app\_mesh) | terraform.registry.launch.nttdata.com/module_primitive/appmesh/aws | ~> 1.0 |
| <a name="module_private_cert"></a> [private\_cert](#module\_private\_cert) | terraform.registry.launch.nttdata.com/module_primitive/acm_private_cert/aws | ~> 1.0 |
| <a name="module_virtual_node"></a> [virtual\_node](#module\_virtual\_node) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [random_integer.priority](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_logical_product_family"></a> [logical\_product\_family](#input\_logical\_product\_family) | (Required) Name of the product family for which the resource is created.<br>    Example: org\_name, department\_name. | `string` | `"launch"` | no |
| <a name="input_logical_product_service"></a> [logical\_product\_service](#input\_logical\_product\_service) | (Required) Name of the product service for which the resource is created.<br>    For example, backend, frontend, middleware etc. | `string` | `"ecs"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment in which the resource should be provisioned like dev, qa, prod etc. | `string` | `"dev"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region in which the infra needs to be provisioned | `string` | `"us-east-2"` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR block for the VPC | `string` | `"10.1.0.0/16"` | no |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | List of private subnet cidrs | `list(string)` | <pre>[<br>  "10.1.1.0/24",<br>  "10.1.2.0/24",<br>  "10.1.3.0/24"<br>]</pre> | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | List of availability zones for the VPC | `list(string)` | <pre>[<br>  "us-east-2a",<br>  "us-east-2b",<br>  "us-east-2c"<br>]</pre> | no |
| <a name="input_tls_enforce"></a> [tls\_enforce](#input\_tls\_enforce) | Whether to enforce TLS on the backends | `bool` | `false` | no |
| <a name="input_tls_mode"></a> [tls\_mode](#input\_tls\_mode) | Mode of TLS. Default is `STRICT`. Allowed values are DISABLED, STRICT and PERMISSIVE. This is required when<br>    `tls_enforce=true` | `string` | `"STRICT"` | no |
| <a name="input_certificate_authority_arns"></a> [certificate\_authority\_arns](#input\_certificate\_authority\_arns) | List of ARNs of private CAs to validate the private certificates | `list(string)` | `[]` | no |
| <a name="input_ports"></a> [ports](#input\_ports) | Application port | `list(number)` | n/a | yes |
| <a name="input_health_check_config"></a> [health\_check\_config](#input\_health\_check\_config) | n/a | <pre>object({<br>    healthy_threshold   = number<br>    interval_millis     = number<br>    timeout_millis      = number<br>    unhealthy_threshold = number<br>  })</pre> | <pre>{<br>  "healthy_threshold": 2,<br>  "interval_millis": 20000,<br>  "timeout_millis": 50000,<br>  "unhealthy_threshold": 2<br>}</pre> | no |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | Destination path for the health check request | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of custom tags to be attached to this resource | `map(string)` | `{}` | no |
| <a name="input_idle_duration"></a> [idle\_duration](#input\_idle\_duration) | Idle duration for all the listeners | <pre>object({<br>    unit  = string<br>    value = number<br>  })</pre> | `null` | no |
| <a name="input_per_request_timeout"></a> [per\_request\_timeout](#input\_per\_request\_timeout) | Per Request timeout for all the listeners | <pre>object({<br>    unit  = string<br>    value = number<br>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | ID of the Virtual Node. |
| <a name="output_arn"></a> [arn](#output\_arn) | ARN of the Virtual Node |
| <a name="output_name"></a> [name](#output\_name) | Name of the Virtual Node |
| <a name="output_random_int"></a> [random\_int](#output\_random\_int) | Random Int postfix |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC Id for the example |
| <a name="output_mesh_name"></a> [mesh\_name](#output\_mesh\_name) | Name of the Mesh |
| <a name="output_node_spec"></a> [node\_spec](#output\_node\_spec) | Node Spec |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
