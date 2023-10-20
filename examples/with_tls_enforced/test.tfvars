ports             = [8080]
health_check_path = "/"
# If this is empty, example module will create one for you. Certs provisioning fails immediately after CA creation. This is the workaround.
certificate_authority_arns   = []
tls_enforce                  = true
tls_mode                     = "STRICT"
naming_prefix                = "demo-app"
environment                  = "dev"
environment_number           = "000"
resource_number              = "000"
region                       = "us-east-2"
vpc_cidr                     = "10.1.0.0/16"
private_subnets              = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
availability_zones           = ["us-east-2a", "us-east-2b", "us-east-2c"]
additional_application_ports = []
service_name                 = ""
cloud_map_attributes         = {}
dns_hostname                 = ""
health_check_config = {
  healthy_threshold   = 2
  interval_millis     = 20000
  timeout_millis      = 50000
  unhealthy_threshold = 2
}
tags = {
  "env" : "gotest",
  "creator" : "terratest",
  "provisioner" : "Terraform",
}
