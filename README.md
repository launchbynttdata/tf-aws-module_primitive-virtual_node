# tf-aws-module_primitive-appmesh_virtual_node

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![License: CC BY-NC-ND 4.0](https://img.shields.io/badge/License-CC_BY--NC--ND_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-nd/4.0/)

## Overview

This Terraform primitive module creates an [AWS App Mesh Virtual Node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appmesh_virtual_node), the App Mesh representation of a logical service (or a specific version of one) that Envoy proxies traffic on behalf of.

- **Listeners** — one or more application ports, all sharing a single protocol (`http`, `http2`, `tcp`, or `grpc`), each with an optional health check, optional per-listener TLS termination via ACM, and idle/per-request timeouts.
- **Service discovery** — the node can be discovered either through AWS Cloud Map (`namespace_name` / `service_name`) or a static DNS hostname (`dns_hostname`); the two are mutually exclusive.
- **Backend TLS** — client-side TLS enforcement (`tls_enforce`) can be applied to this node's outbound connections to its backends, validated against a set of trusted private CA ARNs.
- **Access logging** — access logs are always written to `/dev/stdout` for collection by the container runtime.

## Known Issues and Facts

1. The health checks configured on a listener monitor the health of the underlying service and log the result, but do not evict the ECS task on failure.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.2, < 2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_appmesh_virtual_node.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appmesh_virtual_node) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acm_certificate_arn"></a> [acm\_certificate\_arn](#input\_acm\_certificate\_arn) | ARN of the private certificate to enforce TLS configuration on the Virtual Node | `string` | n/a | yes |
| <a name="input_app_mesh_id"></a> [app\_mesh\_id](#input\_app\_mesh\_id) | ID of the App Mesh to use | `string` | n/a | yes |
| <a name="input_certificate_authority_arns"></a> [certificate\_authority\_arns](#input\_certificate\_authority\_arns) | List of ARNs of private CAs to validate the private certificates | `list(string)` | `[]` | no |
| <a name="input_dns_hostname"></a> [dns\_hostname](#input\_dns\_hostname) | DNS hostname for the Virtual Node to point at. Conflicts with Service Discovery | `string` | `""` | no |
| <a name="input_health_check_config"></a> [health\_check\_config](#input\_health\_check\_config) | n/a | <pre>object({<br/>    healthy_threshold   = number<br/>    interval_millis     = number<br/>    timeout_millis      = number<br/>    unhealthy_threshold = number<br/>  })</pre> | <pre>{<br/>  "healthy_threshold": 2,<br/>  "interval_millis": 50000,<br/>  "timeout_millis": 50000,<br/>  "unhealthy_threshold": 3<br/>}</pre> | no |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | Destination path for the health check request | `string` | `""` | no |
| <a name="input_idle_duration"></a> [idle\_duration](#input\_idle\_duration) | Idle duration for all the listeners | <pre>object({<br/>    unit  = string<br/>    value = number<br/>  })</pre> | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the Virtual Node | `string` | n/a | yes |
| <a name="input_namespace_name"></a> [namespace\_name](#input\_namespace\_name) | Name of the CloudMap Namespace to use for Service Discovery | `string` | `""` | no |
| <a name="input_per_request_timeout"></a> [per\_request\_timeout](#input\_per\_request\_timeout) | Per Request timeout for all the listeners | <pre>object({<br/>    unit  = string<br/>    value = number<br/>  })</pre> | `null` | no |
| <a name="input_ports"></a> [ports](#input\_ports) | Application ports | `list(number)` | `[]` | no |
| <a name="input_protocol"></a> [protocol](#input\_protocol) | Protocol used for port mapping. Valid values are http, http2, tcp and grpc. Currently this same protocol will be used for all listeners | `string` | `"http"` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | CloudMap Service Name to use for this Virtual Node service Discovery | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of custom tags to be attached to this resource | `map(string)` | `{}` | no |
| <a name="input_tls_enforce"></a> [tls\_enforce](#input\_tls\_enforce) | Whether to enforce TLS on the backends | `bool` | `false` | no |
| <a name="input_tls_mode"></a> [tls\_mode](#input\_tls\_mode) | Mode of TLS. Default is `STRICT`. Allowed values are DISABLED, STRICT and PERMISSIVE. This is required when<br/>    `tls_enforce=true` | `string` | `"STRICT"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | ARN of the Virtual Node |
| <a name="output_id"></a> [id](#output\_id) | ID of the Virtual Node. |
| <a name="output_name"></a> [name](#output\_name) | Name of the Virtual Node |
| <a name="output_spec"></a> [spec](#output\_spec) | Node Spec |
<!-- END_TF_DOCS -->

## Module Development

### Pre-Requisites

The following commands should be available on your system:

- `asdf` or `mise`
- `make`
- `python3` (for pre-commit)

Additionally, your `git` user and email must be configured. Run the `make configure` command from the root of the repository to ensure that you meet these requirements.

### Pre-Commit hooks

The [.pre-commit-config.yaml](.pre-commit-config.yaml) file defines certain `pre-commit` hooks that are relevant to Terraform and Golang, as well as some common linting tasks. These will be configured for you when you run `make configure`.

### Local Validation

You should validate the changes you make to any module locally, prior to pushing your changes in a branch to GitHub.

1. Ensure that you have run `make configure` successfully.

2. Ensure you are signed into the appropriate cloud provider (e.g. AWS or Azure) for the module under test in your current console session.

3. Run the Terraform and Golang linters with the following command:

```
make lint
```

4. Once you have satisfied the linters, the following command will build example infrastructure in your configured cloud, run the tests, and then tear down the infrastructure it created:

```
make test
```

The pre-commit validations, as well as the `make lint` and `make test` targets, will all be performed in CI. Running these validations locally prior to opening a PR helps ensure a smooth review and merge process.

### Review & Merge Process

Once your change has been tested locally and your branch pushed up, open a new Pull Request for your branch to the default (main) branch of this repository.

The title of your Pull Request will determine the version bump for this change, and the title must be in [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/#specification) format in order to merge. A breaking change will trigger a major version bump, a feature will trigger a minor version bump, and all other types will trigger a patch version bump.

Ensure your CI workflows are passing; seek approval from teammates and address any feedback; seek any explicit approvals required by the CODEOWNERS file. You may merge the PR as soon as all requirements are met, and a new release and tag will be automatically created for you.

### Automatic Updates

The shared configuration and workflow files in this repository are largely managed through the [launch-terraform-skeleton](https://github.com/launchbynttdata/launch-terraform-skeleton) repository. Outside of perhaps the `.gitignore` to account for specific files being generated by certain Terraform modules (e.g. Lambda functions), there should not be much cause to update these files on a per-repo basis, and making changes to them individually is discouraged.

If desired, you can check for and run these updates locally in a branch if you have the `copier` tool installed. Some example commands are included below:

```
# Check for updates, optionally checking prerelease versions
copier check-update [--prereleases]

# Run an update, using default answers if there are any. We use tasks, which requires --trust to be set.
copier update --defaults --trust [--prereleases]

# Recopy from the source, and --overwrite all templated files in the process
copier recopy --defaults --trust --overwrite [--prereleases]
```

Automatic updates will run through a scheduled workflow, and if the post-update tests are successful, the Pull Request created will automatically merge. Conflicts in the update or failures to test may leave a Pull Request outstanding, which needs to be addressed by a Launch Engineer.
