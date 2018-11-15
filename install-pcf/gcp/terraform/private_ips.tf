// Private static IP address for ILB that fronts HAProxy
resource "google_compute_address" "internal_gorouter" {
  name         = "${var.prefix}-gorouter"
  subnetwork   = "${data.google_compute_subnetwork.gcp_existing_ops_man_subnet.self_link}"
  address_type = "INTERNAL"
}

// Private static IP address for ILB that fronts ssh-proxy
resource "google_compute_address" "internal_ssh_proxy" {
  name         = "${var.prefix}-ssh-haproxy"
  subnetwork   = "${data.google_compute_subnetwork.gcp_existing_ops_man_subnet.self_link}"
  address_type = "INTERNAL"
}

// Private static IP address for ILB that fronts loggregator/doppler
resource "google_compute_address" "internal_wss_logs" {
  name         = "${var.prefix}-wss-logs"
  subnetwork   = "${data.google_compute_subnetwork.gcp_existing_ops_man_subnet.self_link}"
  address_type = "INTERNAL"
}
