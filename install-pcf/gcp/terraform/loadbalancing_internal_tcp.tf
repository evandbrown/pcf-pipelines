resource "google_compute_forwarding_rule" "cf-haproxy" {
  name        = "${var.prefix}-haproxy-lb"
  backend_service     = "${google_compute_region_backend_service.cf-haproxy.self_link}"
  ports = ["80", "443"]
  network                = "${google_compute_network.pcf-virt-net.self_link}"
  subnetwork = "${google_compute_subnetwork.subnet-ops-manager.self_link}"
  load_balancing_scheme = "INTERNAL"
}

resource "google_compute_instance_group" "cf-haproxy" {
  count       = 3
  name        = "${var.prefix}-haproxy-lb"
  description = "terraform generated pcf instance group that is multi-zone for tcp load balancing to haproxy"
  
  zone        = "${element(list(var.gcp_zone_1,var.gcp_zone_2,var.gcp_zone_3), count.index)}"
  network                = "${google_compute_network.pcf-virt-net.self_link}"
}

resource "google_compute_region_backend_service" "cf-haproxy" {
  name        = "${var.prefix}-haproxy-lb-backend"
  protocol    = "TCP"
  timeout_sec = 10

  backend {
    group = "${google_compute_instance_group.cf-haproxy.0.self_link}"
  }

  backend {
    group = "${google_compute_instance_group.cf-haproxy.1.self_link}"
  }

  backend {
    group = "${google_compute_instance_group.cf-haproxy.2.self_link}"
  }

  health_checks = ["${google_compute_health_check.cf-haproxy.self_link}"]
}

resource "google_compute_health_check" "cf-haproxy" {
  name        = "${var.prefix}-haproxy-lb-healthcheck"
  check_interval_sec = 5
  timeout_sec        = 5

  ssl_health_check {}
}
