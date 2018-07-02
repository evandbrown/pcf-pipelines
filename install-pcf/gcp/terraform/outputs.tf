// Core Project Output

output "project" {
  value = "${var.gcp_proj_id}"
}

output "host_network_project" {
  value = "${var.gcp_host_net_proj_id}"
}

output "region" {
  value = "${var.gcp_region}"
}

output "azs" {
  value = "${var.gcp_zone_1},${var.gcp_zone_2},${var.gcp_zone_3}"
}

output "deployment-prefix" {
  value = "${var.prefix}-vms"
}

// DNS Output

output "ops_manager_dns" {
  value = "${google_dns_record_set.ops-manager-dns.name}"
}

output "sys_domain" {
  value = "${var.system_domain}"
}

output "apps_domain" {
  value = "${var.apps_domain}"
}

output "tcp_domain" {
  value = "tcp.${var.pcf_ert_domain}"
}

output "ops_manager_public_ip" {
  value = "${google_compute_instance.ops-manager.network_interface.0.address}"
}

output "env_dns_zone_name_servers" {
  value = "${google_dns_managed_zone.env_dns_zone.name_servers}"
}

// Network Output

output "network_name" {
  value = "${data.google_compute_network.gcp_existing_virt_net.name}"
}

output "ops_manager_gateway" {
  value = "${data.google_compute_subnetwork.gcp_existing_ops_man_subnet.gateway_address}"
}

output "ops_manager_reserved_range" {
  value = "${data.google_compute_subnetwork.gcp_existing_ops_man_subnet.gateway_address}-${cidrhost(data.google_compute_subnetwork.gcp_existing_ops_man_subnet.ip_cidr_range, 20)}"
}

output "ops_manager_cidr" {
  value = "${data.google_compute_subnetwork.gcp_existing_ops_man_subnet.ip_cidr_range}"
}

output "ops_manager_subnet" {
  value = "${data.google_compute_subnetwork.gcp_existing_ops_man_subnet.name}"
}

output "ert_gateway" {
  value = "${data.google_compute_subnetwork.gcp_existing_ert_subnet.gateway_address}"
}

output "ert_reserved_range" {
  value = "${data.google_compute_subnetwork.gcp_existing_ert_subnet.gateway_address}-${cidrhost(data.google_compute_subnetwork.gcp_existing_ert_subnet.ip_cidr_range, 20)}"
}

output "ert_cidr" {
  value = "${data.google_compute_subnetwork.gcp_existing_ert_subnet.ip_cidr_range}"
}

output "ert_subnet" {
  value = "${data.google_compute_subnetwork.gcp_existing_ert_subnet.name}"
}

output "svc_net_1_gateway" {
  value = "${data.google_compute_subnetwork.gcp_existing_services_subnet.gateway_address}"
}

output "svc_net_1_reserved_range" {
  value = "${data.google_compute_subnetwork.gcp_existing_services_subnet.gateway_address}-${cidrhost(data.google_compute_subnetwork.gcp_existing_services_subnet.ip_cidr_range, 20)}"
}

output "svc_net_1_cidr" {
  value = "${data.google_compute_subnetwork.gcp_existing_services_subnet.ip_cidr_range}"
}

output "svc_net_1_subnet" {
  value = "${data.google_compute_subnetwork.gcp_existing_services_subnet.name}"
}

output "dynamic_svc_net_1_gateway" {
  value = "${data.google_compute_subnetwork.gcp_existing_dynamic_services_subnet.gateway_address}"
}

output "dynamic_svc_net_1_reserved_range" {
  value = "${data.google_compute_subnetwork.gcp_existing_dynamic_services_subnet.gateway_address}-${cidrhost(data.google_compute_subnetwork.gcp_existing_dynamic_services_subnet.ip_cidr_range, 20)}"
}

output "dynamic_svc_net_1_cidr" {
  value = "${data.google_compute_subnetwork.gcp_existing_dynamic_services_subnet.ip_cidr_range}"
}

output "dynamic_svc_net_1_subnet" {
  value = "${data.google_compute_subnetwork.gcp_existing_dynamic_services_subnet.name}"
}

// Http Load Balancer Output

//output "http_lb_backend_name" {
//  value = "${google_compute_backend_service.ert_http_lb_backend_service.name}"
//}

//output "tcp_router_pool" {
//  value = "${google_compute_target_pool.cf-tcp.name}"
//}

// Cloud Storage Bucket Output

output "buildpacks_bucket" {
  value = "${google_storage_bucket.buildpacks.name}"
}

output "droplets_bucket" {
  value = "${google_storage_bucket.droplets.name}"
}

output "packages_bucket" {
  value = "${google_storage_bucket.packages.name}"
}

output "resources_bucket" {
  value = "${google_storage_bucket.resources.name}"
}

output "director_blobstore_bucket" {
  value = "${google_storage_bucket.director.name}"
}

////output "pub_ip_global_pcf" {
////  value = "${google_compute_global_address.pcf.address}"
////}
////
////output "pub_ip_ssh_and_doppler" {
////  value = "${google_compute_address.ssh-and-doppler.address}"
////}
////
////output "pub_ip_ssh_tcp_lb" {
////  value = "${google_compute_address.cf-tcp.address}"
////}
////
////output "pub_ip_opsman" {
////  value = "${google_compute_address.opsman.address}"
////}

output "priv_ip_opsman" {
  value = "${google_compute_instance.ops-manager.network_interface.0.address}"
}

output "sql_instance_ip" {
  value = "${google_sql_database_instance.master.ip_address.0.ip_address}"
}

output "ert_certificate" {
  value = "${google_compute_ssl_certificate.ssl-cert.certificate}"
}

output "ert_certificate_key" {
  value = "${google_compute_ssl_certificate.ssl-cert.private_key}"
}
