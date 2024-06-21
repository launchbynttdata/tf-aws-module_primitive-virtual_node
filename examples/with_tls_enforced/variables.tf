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

variable "logical_product_family" {
  type        = string
  description = <<EOF
    (Required) Name of the product family for which the resource is created.
    Example: org_name, department_name.
  EOF
  nullable    = false

  validation {
    condition     = can(regex("^[_\\-A-Za-z0-9]+$", var.logical_product_family))
    error_message = "The variable must contain letters, numbers, -, _, and .."
  }

  default = "launch"
}

variable "logical_product_service" {
  type        = string
  description = <<EOF
    (Required) Name of the product service for which the resource is created.
    For example, backend, frontend, middleware etc.
  EOF
  nullable    = false

  validation {
    condition     = can(regex("^[_\\-A-Za-z0-9]+$", var.logical_product_service))
    error_message = "The variable must contain letters, numbers, -, _, and .."
  }

  default = "ecs"
}

variable "environment" {
  description = "Environment in which the resource should be provisioned like dev, qa, prod etc."
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS Region in which the infra needs to be provisioned"
  type        = string
  default     = "us-east-2"
}

## VPC related variables
### VPC related variables

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "private_subnets" {
  description = "List of private subnet cidrs"
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones for the VPC"
  type        = list(string)
  default     = ["us-east-2a", "us-east-2b", "us-east-2c"]
}

## Virtual Node related variables

variable "tls_enforce" {
  description = "Whether to enforce TLS on the backends"
  type        = bool
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

variable "certificate_authority_arns" {
  description = "List of ARNs of private CAs to validate the private certificates"
  type        = list(string)
  default     = []
}

## Service Discovery

## DNS (conflicts with Service Discovery)
variable "ports" {
  description = "Application port"
  type        = list(number)
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
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of custom tags to be attached to this resource"
  type        = map(string)
  default     = {}
}

variable "idle_duration" {
  description = "Idle duration for all the listeners"
  type = object({
    unit  = string
    value = number
  })
  default = null
}

variable "per_request_timeout" {
  description = "Per Request timeout for all the listeners"
  type = object({
    unit  = string
    value = number
  })
  default = null
}
