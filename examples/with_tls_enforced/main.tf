// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

resource "random_integer" "priority" {
  min = 10000
  max = 50000
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name                 = "test-vpc-${local.random_id}"
  cidr                 = var.vpc_cidr
  private_subnets      = var.private_subnets
  azs                  = var.availability_zones
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = var.tags
}

module "private_ca" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/private_ca/aws"
  version = "~> 1.0"

  count = length(var.certificate_authority_arns) == 0 ? 1 : 0

  logical_product_family  = var.logical_product_family
  logical_product_service = local.logical_product_service
  region                  = var.region
  environment             = var.environment

}

module "namespace" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/private_dns_namespace/aws"
  version = "~> 1.0"

  vpc_id = module.vpc.vpc_id
  name   = local.namespace_name

}

module "app_mesh" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/appmesh/aws"
  version = "~> 1.0"

  name = local.app_mesh_name
}

module "private_cert" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/acm_private_cert/aws"
  version = "~> 1.0"

  # Private CA is created if not passed as input
  private_ca_arn = length(var.certificate_authority_arns) == 0 ? module.private_ca[0].private_ca_arn : var.certificate_authority_arns[0]
  domain_name    = "test.${local.namespace_name}"
}

module "virtual_node" {
  source = "../.."

  acm_certificate_arn        = module.private_cert.certificate_arn
  ports                      = var.ports
  namespace_name             = local.namespace_name
  name                       = local.name
  app_mesh_id                = module.app_mesh.id
  service_name               = local.service_name
  health_check_path          = var.health_check_path
  tls_enforce                = var.tls_enforce
  tls_mode                   = var.tls_mode
  certificate_authority_arns = length(var.certificate_authority_arns) > 0 ? var.certificate_authority_arns : [module.private_ca[0].private_ca_arn]
  health_check_config        = var.health_check_config
  idle_duration              = var.idle_duration
  per_request_timeout        = var.per_request_timeout
  tags                       = var.tags

}
