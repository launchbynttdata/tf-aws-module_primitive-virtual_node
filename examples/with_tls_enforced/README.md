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

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | 3.5.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 5.0.0 |
| <a name="module_private_ca"></a> [private\_ca](#module\_private\_ca) | git::https://github.com/launchbynttdata/tf-aws-module_primitive-private_ca | 1.0.0 |
| <a name="module_namespace"></a> [namespace](#module\_namespace) | git::https://github.com/launchbynttdata/tf-aws-module_primitive-private_dns_namespace | 1.0.0 |
| <a name="module_app_mesh"></a> [app\_mesh](#module\_app\_mesh) | git::https://github.com/launchbynttdata/tf-aws-module_primitive-appmesh | 1.0.0 |
| <a name="module_private_cert"></a> [private\_cert](#module\_private\_cert) | git::https://github.com/launchbynttdata/tf-aws-module_primitive-acm_private_cert | 1.0.0 |
| <a name="module_virtual_node"></a> [virtual\_node](#module\_virtual\_node) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [random_integer.priority](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_naming_prefix"></a> [naming\_prefix](#input\_naming\_prefix) | Prefix for the provisioned resources. | `string` | `"demo-app"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment in which the resource should be provisioned like dev, qa, prod etc. | `string` | `"dev"` | no |
| <a name="input_environment_number"></a> [environment\_number](#input\_environment\_number) | The environment count for the respective environment. Defaults to 000. Increments in value of 1 | `string` | `"000"` | no |
| <a name="input_resource_number"></a> [resource\_number](#input\_resource\_number) | The resource count for the respective resource. Defaults to 000. Increments in value of 1 | `string` | `"000"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region in which the infra needs to be provisioned | `string` | `"us-east-2"` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | n/a | `string` | `"10.1.0.0/16"` | no |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | List of private subnet cidrs | `list` | <pre>[<br>  "10.1.1.0/24",<br>  "10.1.2.0/24",<br>  "10.1.3.0/24"<br>]</pre> | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | List of availability zones for the VPC | `list` | <pre>[<br>  "us-east-2a",<br>  "us-east-2b",<br>  "us-east-2c"<br>]</pre> | no |
| <a name="input_tls_enforce"></a> [tls\_enforce](#input\_tls\_enforce) | Whether to enforce TLS on the backends | `bool` | `false` | no |
| <a name="input_tls_mode"></a> [tls\_mode](#input\_tls\_mode) | Mode of TLS. Default is `STRICT`. Allowed values are DISABLED, STRICT and PERMISSIVE. This is required when<br>    `tls_enforce=true` | `string` | `"STRICT"` | no |
| <a name="input_additional_application_ports"></a> [additional\_application\_ports](#input\_additional\_application\_ports) | Additional ports at which the application listens to | `list(number)` | `[]` | no |
| <a name="input_certificate_authority_arns"></a> [certificate\_authority\_arns](#input\_certificate\_authority\_arns) | List of ARNs of private CAs to validate the private certificates | `list(string)` | `[]` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | CloudMap Service Name to use for this Virtual Node service Discovery | `string` | `""` | no |
| <a name="input_cloud_map_attributes"></a> [cloud\_map\_attributes](#input\_cloud\_map\_attributes) | A map of strings to filter instances by any custom attributes | `map(string)` | `{}` | no |
| <a name="input_dns_hostname"></a> [dns\_hostname](#input\_dns\_hostname) | DNS hostname for the Virtual Node to point at. Conflicts with Service Discovery | `string` | `""` | no |
| <a name="input_ports"></a> [ports](#input\_ports) | Application port | `list(number)` | n/a | yes |
| <a name="input_protocol"></a> [protocol](#input\_protocol) | Protocol used for port mapping. Valid values are http, http2, tcp and grpc | `string` | `"http"` | no |
| <a name="input_health_check_config"></a> [health\_check\_config](#input\_health\_check\_config) | n/a | <pre>object({<br>    healthy_threshold   = number<br>    interval_millis     = number<br>    timeout_millis      = number<br>    unhealthy_threshold = number<br>  })</pre> | <pre>{<br>  "healthy_threshold": 2,<br>  "interval_millis": 20000,<br>  "timeout_millis": 50000,<br>  "unhealthy_threshold": 2<br>}</pre> | no |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | Destination path for the health check request | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of custom tags to be attached to this resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | ID of the Virtual Node. |
| <a name="output_arn"></a> [arn](#output\_arn) | ARN of the Virtual Node |
| <a name="output_name"></a> [name](#output\_name) | Name of the Virtual Node |
| <a name="output_random_int"></a> [random\_int](#output\_random\_int) | Random Int postfix |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC Id for the example |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
