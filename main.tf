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

resource "aws_appmesh_virtual_node" "this" {
  name      = var.name
  mesh_name = var.app_mesh_id

  spec {
    backend_defaults {
      client_policy {
        dynamic "tls" {
          for_each = var.tls_enforce ? [1] : []
          content {
            enforce = true
            ports   = var.ports
            validation {
              trust {
                acm {
                  certificate_authority_arns = var.certificate_authority_arns
                }
              }
            }
          }
        }
      }
    }
    dynamic "listener" {
      for_each = var.ports
      content {
        port_mapping {
          port     = listener.value
          protocol = var.protocol
        }

        dynamic "health_check" {
          for_each = length(var.health_check_path) > 0 ? [1] : []
          content {
            port                = listener.value
            protocol            = var.protocol
            path                = var.health_check_path
            healthy_threshold   = var.health_check_config.healthy_threshold
            unhealthy_threshold = var.health_check_config.unhealthy_threshold
            timeout_millis      = var.health_check_config.timeout_millis
            interval_millis     = var.health_check_config.interval_millis
          }
        }

        dynamic "tls" {
          for_each = var.tls_enforce ? [1] : []
          content {
            certificate {
              acm {
                certificate_arn = var.acm_certificate_arn
              }
            }
            mode = var.tls_mode
          }
        }
        timeout {
          dynamic "http" {
            for_each = var.protocol == "http" ? [1] : []
            content {
              dynamic "idle" {
                for_each = var.idle_duration != null ? [1] : []
                content {
                  unit  = var.idle_duration.unit
                  value = var.idle_duration.value
                }
              }
              dynamic "per_request" {
                for_each = var.per_request_timeout != null ? [1] : []
                content {
                  unit  = var.per_request_timeout.unit
                  value = var.per_request_timeout.value
                }
              }
            }
          }

          dynamic "http2" {
            for_each = var.protocol == "http2" ? [1] : []
            content {
              dynamic "idle" {
                for_each = var.idle_duration != null ? [1] : []
                content {
                  unit  = var.idle_duration.unit
                  value = var.idle_duration.value
                }
              }
              dynamic "per_request" {
                for_each = var.per_request_timeout != null ? [1] : []
                content {
                  unit  = var.per_request_timeout.unit
                  value = var.per_request_timeout.value
                }
              }
            }
          }

          dynamic "grpc" {
            for_each = var.protocol == "grpc" ? [1] : []
            content {
              dynamic "idle" {
                for_each = var.idle_duration != null ? [1] : []
                content {
                  unit  = var.idle_duration.unit
                  value = var.idle_duration.value
                }
              }
              dynamic "per_request" {
                for_each = var.per_request_timeout != null ? [1] : []
                content {
                  unit  = var.per_request_timeout.unit
                  value = var.per_request_timeout.value
                }
              }
            }
          }

          dynamic "tcp" {
            for_each = var.protocol == "tcp" ? [1] : []
            content {
              dynamic "idle" {
                for_each = var.idle_duration != null ? [1] : []
                content {
                  unit  = var.idle_duration.unit
                  value = var.idle_duration.value
                }
              }
            }
          }
        }
      }
    }


    service_discovery {
      dynamic "aws_cloud_map" {
        for_each = length(var.namespace_name) > 0 ? [1] : []
        content {
          service_name   = var.service_name
          namespace_name = var.namespace_name
        }
      }

      dynamic "dns" {
        for_each = length(var.dns_hostname) > 0 ? [1] : []
        content {
          hostname = var.dns_hostname
        }
      }
    }

    logging {
      access_log {
        file {
          path = "/dev/stdout"
        }
      }
    }
  }

  tags = local.tags
}
