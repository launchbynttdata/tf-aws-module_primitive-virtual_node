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

variable "naming_prefix" {
  description = "Prefix for the provisioned resources."
  type        = string
  default     = "demo-app"
}

variable "environment" {
  description = "Environment in which the resource should be provisioned like dev, qa, prod etc."
  type        = string
  default     = "dev"
}

variable "environment_number" {
  description = "The environment count for the respective environment. Defaults to 000. Increments in value of 1"
  default     = "000"
}

variable "resource_number" {
  description = "The resource count for the respective resource. Defaults to 000. Increments in value of 1"
  default     = "000"
}

variable "region" {
  description = "AWS Region in which the infra needs to be provisioned"
  default     = "us-east-2"
}

## VPC related variables
### VPC related variables

variable "vpc_cidr" {
  default = "10.1.0.0/16"
}

variable "private_subnets" {
  description = "List of private subnet cidrs"
  default     = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones for the VPC"
  default     = ["us-east-2a", "us-east-2b", "us-east-2c"]
}

## Virtual Node related variables

variable "tls_enforce" {
  description = "Whether to enforce TLS on the backends"
  default     = false
}

variable "tls_mode" {
  description = <<EOF
    Mode of TLS. Default is `STRICT`. Allowed values are DISABLED, STRICT and PERMISSIVE. This is required when
    `tls_enforce=true`
  EOF
  type        = string
  default     = "STRICT"
}

variable "additional_application_ports" {
  description = "Additional ports at which the application listens to"
  type        = list(number)
  default     = []
}

variable "certificate_authority_arns" {
  description = "List of ARNs of private CAs to validate the private certificates"
  type        = list(string)
  default     = []
}

## Service Discovery

variable "service_name" {
  description = "CloudMap Service Name to use for this Virtual Node service Discovery"
  type        = string
  default     = ""
}

variable "cloud_map_attributes" {
  description = "A map of strings to filter instances by any custom attributes"
  type        = map(string)
  default     = {}
}

## DNS (conflicts with Service Discovery)
variable "dns_hostname" {
  description = "DNS hostname for the Virtual Node to point at. Conflicts with Service Discovery"
  type        = string
  default     = ""
}

variable "ports" {
  description = "Application port"
  type        = list(number)
}

variable "protocol" {
  description = "Protocol used for port mapping. Valid values are http, http2, tcp and grpc"
  type        = string
  default     = "http"
}

variable "health_check_config" {
  type = object({
    healthy_threshold   = number
    interval_millis     = number
    timeout_millis      = number
    unhealthy_threshold = number
  })

  default = {
    healthy_threshold   = 2
    interval_millis     = 20000
    timeout_millis      = 50000
    unhealthy_threshold = 2
  }
}

variable "health_check_path" {
  description = "Destination path for the health check request"
  default     = ""
}

variable "tags" {
  description = "A map of custom tags to be attached to this resource"
  type        = map(string)
  default     = {}
}
