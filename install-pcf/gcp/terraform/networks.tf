data "google_compute_network" "gcp_existing_virt_net" {
  name    = "${var.gcp_existing_virt_net}"
  project = "${var.gcp_host_net_proj_id}"
}

// Ops Manager & Jumpbox
data "google_compute_subnetwork" "gcp_existing_ops_man_subnet" {
  name    = "${var.gcp_existing_ops_man_subnet}"
  project = "${var.gcp_host_net_proj_id}"
}

// ERT
data "google_compute_subnetwork" "gcp_existing_ert_subnet" {
  name    = "${var.gcp_existing_ert_subnet}"
  project = "${var.gcp_host_net_proj_id}"
}

// Services Tile
data "google_compute_subnetwork" "gcp_existing_services_subnet" {
  name    = "${var.gcp_existing_services_subnet}"
  project = "${var.gcp_host_net_proj_id}"
}

// Dynamic Services Tile
data "google_compute_subnetwork" "gcp_existing_dynamic_services_subnet" {
  name    = "${var.gcp_existing_dynamic_services_subnet}"
  project = "${var.gcp_host_net_proj_id}"
}
