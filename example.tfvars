# User needs to populate all the fields in <> in order to use this with `terraform plan|apply`

app_mesh_id                = "<app_mesh_id_or_name>"
name                       = "<virtual_node_name>"
namespace_name             = "<cloudmap_namespace_name>"
service_name               = "<virtual_service_name>"
tls_enforce                = true
ports                      = ["<list of app_ports>"]
protocol                   = "http"
certificate_authority_arns = ["<arn_private_ca>"]
acm_certificate_arn        = "<arn_of_private_cert>"
health_check_path          = "/"
