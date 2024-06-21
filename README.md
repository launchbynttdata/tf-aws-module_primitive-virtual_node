# tf-aws-module_primitive-appmesh_virtual_node

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![License: CC BY-NC-ND 4.0](https://img.shields.io/badge/License-CC_BY--NC--ND_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-nd/4.0/)

## Overview

This terraform module creates a Virtual Node in a Service Mesh provided as input.
## Usage
A sample variable file `example.tfvars` is available in the root directory which can be used to test this module. User needs to follow the below steps to execute this module
1. Update the `example.tfvars` to manually enter values for all fields marked within `<>` to make the variable file usable
2. Create a file `provider.tf` with the below contents
   ```
    provider "aws" {
      profile = "<profile_name>"
      region  = "<region_name>"
    }
    ```
   If using `SSO`, make sure you are logged in `aws sso login --profile <profile_name>`
3. Make sure terraform binary is installed on your local. Use command `type terraform` to find the installation location. If you are using `asdf`, you can run `asfd install` and it will install the correct terraform version for you. `.tool-version` contains all the dependencies.
4. Run the `terraform` to provision infrastructure on AWS
    ```
    # Initialize
    terraform init
    # Plan
    terraform plan -var-file example.tfvars
    # Apply (this is create the actual infrastructure)
    terraform apply -var-file example.tfvars -auto-approve
   ```
## Known Issues and Facts

1. The health checks in the listener checks the health of the underlying service and logs it, but doesn't evict the ECS task in case of failures.

## Pre-Commit hooks

[.pre-commit-config.yaml](.pre-commit-config.yaml) file defines certain `pre-commit` hooks that are relevant to terraform, golang and common linting tasks. There are no custom hooks added.

`commitlint` hook enforces commit message in certain format. The commit contains the following structural elements, to communicate intent to the consumers of your commit messages:

- **fix**: a commit of the type `fix` patches a bug in your codebase (this correlates with PATCH in Semantic Versioning).
- **feat**: a commit of the type `feat` introduces a new feature to the codebase (this correlates with MINOR in Semantic Versioning).
- **BREAKING CHANGE**: a commit that has a footer `BREAKING CHANGE:`, or appends a `!` after the type/scope, introduces a breaking API change (correlating with MAJOR in Semantic Versioning). A BREAKING CHANGE can be part of commits of any type.
footers other than BREAKING CHANGE: <description> may be provided and follow a convention similar to git trailer format.
- **build**: a commit of the type `build` adds changes that affect the build system or external dependencies (example scopes: gulp, broccoli, npm)
- **chore**: a commit of the type `chore` adds changes that don't modify src or test files
- **ci**: a commit of the type `ci` adds changes to our CI configuration files and scripts (example scopes: Travis, Circle, BrowserStack, SauceLabs)
- **docs**: a commit of the type `docs` adds documentation only changes
- **perf**: a commit of the type `perf` adds code change that improves performance
- **refactor**: a commit of the type `refactor` adds code change that neither fixes a bug nor adds a feature
- **revert**: a commit of the type `revert` reverts a previous commit
- **style**: a commit of the type `style` adds code changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
- **test**: a commit of the type `test` adds missing tests or correcting existing tests

Base configuration used for this project is [commitlint-config-conventional (based on the Angular convention)](https://github.com/conventional-changelog/commitlint/tree/master/@commitlint/config-conventional#type-enum)

If you are a developer using vscode, [this](https://marketplace.visualstudio.com/items?itemName=joshbolduc.commitlint) plugin may be helpful.

`detect-secrets-hook` prevents new secrets from being introduced into the baseline. TODO: INSERT DOC LINK ABOUT HOOKS

In order for `pre-commit` hooks to work properly

- You need to have the pre-commit package manager installed. [Here](https://pre-commit.com/#install) are the installation instructions.
- `pre-commit` would install all the hooks when commit message is added by default except for `commitlint` hook. `commitlint` hook would need to be installed manually using the command below

```
pre-commit install --hook-type commit-msg
```

## To test the resource group module locally

1. For development/enhancements to this module locally, you'll need to install all of its components. This is controlled by the `configure` target in the project's [`Makefile`](./Makefile). Before you can run `configure`, familiarize yourself with the variables in the `Makefile` and ensure they're pointing to the right places.

```
make configure
```

This adds in several files and directories that are ignored by `git`. They expose many new Make targets.

2. The first target you care about is `env`. This is the common interface for setting up environment variables. The values of the environment variables will be used to authenticate with cloud provider from local development workstation.

`make configure` command will bring down `aws_env.sh` file on local workstation. Developer would need to modify this file, replace the environment variable values with relevant values.

These environment variables are used by `terratest` integration suit.

Then run this make target to set the environment variables on developer workstation.

```
make env
```

3. The first target you care about is `check`.

**Pre-requisites**
Before running this target it is important to ensure that, developer has created files mentioned below on local workstation under root directory of git repository that contains code for primitives/segments. Note that these files are `aws` specific. If primitive/segment under development uses any other cloud provider than AWS, this section may not be relevant.

- A file named `provider.tf` with contents below

```
provider "aws" {
  profile = "<profile_name>"
  region  = "<region_name>"
}
```

- A file named `terraform.tfvars` which contains key value pair of variables used.

Note that since these files are added in `gitignore` they would not be checked in into primitive/segment's git repo.

After creating these files, for running tests associated with the primitive/segment, run

```
make check
```

If `make check` target is successful, developer is good to commit the code to primitive/segment's git repo.

`make check` target

- runs `terraform commands` to `lint`,`validate` and `plan` terraform code.
- runs `conftests`. `conftests` make sure `policy` checks are successful.
- runs `terratest`. This is integration test suit.
- runs `opa` tests

# Know Issues
Currently, the `encrypt at transit` is not supported in terraform. There is an open issue for this logged with Hashicorp - https://github.com/hashicorp/terraform-provider-aws/pull/26987

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0, <= 1.5.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.28.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.67.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_appmesh_virtual_node.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appmesh_virtual_node) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name of the Virtual Node | `string` | n/a | yes |
| <a name="input_app_mesh_id"></a> [app\_mesh\_id](#input\_app\_mesh\_id) | ID of the App Mesh to use | `string` | n/a | yes |
| <a name="input_tls_enforce"></a> [tls\_enforce](#input\_tls\_enforce) | Whether to enforce TLS on the backends | `bool` | `false` | no |
| <a name="input_tls_mode"></a> [tls\_mode](#input\_tls\_mode) | Mode of TLS. Default is `STRICT`. Allowed values are DISABLED, STRICT and PERMISSIVE. This is required when<br>    `tls_enforce=true` | `string` | `"STRICT"` | no |
| <a name="input_additional_application_ports"></a> [additional\_application\_ports](#input\_additional\_application\_ports) | Additional ports at which the application listens to | `list(number)` | `[]` | no |
| <a name="input_acm_certificate_arn"></a> [acm\_certificate\_arn](#input\_acm\_certificate\_arn) | ARN of the private certificate to enforce TLS configuration on the Virtual Node | `any` | n/a | yes |
| <a name="input_certificate_authority_arns"></a> [certificate\_authority\_arns](#input\_certificate\_authority\_arns) | List of ARNs of private CAs to validate the private certificates | `list(string)` | `[]` | no |
| <a name="input_namespace_name"></a> [namespace\_name](#input\_namespace\_name) | Name of the CloudMap Namespace to use for Service Discovery | `string` | `""` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | CloudMap Service Name to use for this Virtual Node service Discovery | `string` | `""` | no |
| <a name="input_cloud_map_attributes"></a> [cloud\_map\_attributes](#input\_cloud\_map\_attributes) | A map of strings to filter instances by any custom attributes | `map(string)` | `{}` | no |
| <a name="input_dns_hostname"></a> [dns\_hostname](#input\_dns\_hostname) | DNS hostname for the Virtual Node to point at. Conflicts with Service Discovery | `string` | `""` | no |
| <a name="input_ports"></a> [ports](#input\_ports) | Application ports | `list(number)` | `[]` | no |
| <a name="input_protocol"></a> [protocol](#input\_protocol) | Protocol used for port mapping. Valid values are http, http2, tcp and grpc. Currently this same protocol will be used for all listeners | `string` | `"http"` | no |
| <a name="input_health_check_config"></a> [health\_check\_config](#input\_health\_check\_config) | n/a | <pre>object({<br>    healthy_threshold   = number<br>    interval_millis     = number<br>    timeout_millis      = number<br>    unhealthy_threshold = number<br>  })</pre> | <pre>{<br>  "healthy_threshold": 2,<br>  "interval_millis": 50000,<br>  "timeout_millis": 50000,<br>  "unhealthy_threshold": 3<br>}</pre> | no |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | Destination path for the health check request | `string` | `""` | no |
| <a name="input_idle_duration"></a> [idle\_duration](#input\_idle\_duration) | Idle duration for all the listeners | <pre>object({<br>    unit  = string<br>    value = number<br>  })</pre> | `null` | no |
| <a name="input_per_request_timeout"></a> [per\_request\_timeout](#input\_per\_request\_timeout) | Per Request timeout for all the listeners | <pre>object({<br>    unit  = string<br>    value = number<br>  })</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of custom tags to be attached to this resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | ID of the Virtual Node. |
| <a name="output_arn"></a> [arn](#output\_arn) | ARN of the Virtual Node |
| <a name="output_name"></a> [name](#output\_name) | Name of the Virtual Node |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
