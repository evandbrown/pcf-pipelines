resource "google_compute_instance" "ops-manager" {
  name         = "${var.prefix}-ops-manager"
  depends_on   = ["data.google_compute_subnetwork.gcp_existing_ops_man_subnet"]
  machine_type = "n1-standard-2"
  zone         = "${var.gcp_zone_1}"

  tags = ["${var.prefix}", "${var.prefix}-opsman", "allow-https"]

  boot_disk {
    initialize_params {
      image = "${var.pcf_opsman_image_name}"
      size  = 50
    }
  }

  network_interface {
    subnetwork = "${data.google_compute_subnetwork.gcp_existing_ops_man_subnet.name}"
    network_ip = "${google_compute_address.internal_ops_man.address}"
  }
}

resource "google_storage_bucket" "director" {
  name          = "${var.prefix}-director"
  location      = "${var.gcp_storage_bucket_location}"
  force_destroy = true
}
