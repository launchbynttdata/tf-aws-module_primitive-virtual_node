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

variable "name" {
  description = "Name of the Virtual Node"
  type        = string
}

variable "app_mesh_id" {
  description = "ID of the App Mesh to use"
  type        = string
}

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

variable "acm_certificate_arn" {
  description = "ARN of the private certificate to enforce TLS configuration on the Virtual Node"
  type        = string
}

variable "certificate_authority_arns" {
  description = "List of ARNs of private CAs to validate the private certificates"
  type        = list(string)
  default     = []
}

## Service Discovery

variable "namespace_name" {
  description = "Name of the CloudMap Namespace to use for Service Discovery"
  type        = string
  default     = ""
}

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
  description = "Application ports"
  type        = list(number)
  default     = []
}

variable "protocol" {
  description = "Protocol used for port mapping. Valid values are http, http2, tcp and grpc. Currently this same protocol will be used for all listeners"
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
    interval_millis     = 50000
    timeout_millis      = 50000
    unhealthy_threshold = 3
  }
}

variable "health_check_path" {
  description = "Destination path for the health check request"
  type        = string
  default     = ""
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

variable "tags" {
  description = "A map of custom tags to be attached to this resource"
  type        = map(string)
  default     = {}
}
