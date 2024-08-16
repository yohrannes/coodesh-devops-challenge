provider "google" {}

#docker run -it -v $PWD:/root -w /root --entrypoint "" hashicorp/terraform:light sh

resource "google_compute_network" "vpc_network" {
  name                    = "cd-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "cd-subnet"
  ip_cidr_range = "10.0.0.0/24"
  network       = google_compute_network.vpc_network.self_link
}

resource "google_compute_firewall" "default-allow-http-https-ssh-icmp" {
  name        = "cd-allow-http-https-ssh-icmp"
  network     = google_compute_network.vpc_network.self_link

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance" "coodesh-webserver" {
  boot_disk {
    auto_delete = true
    device_name = "webserver-coodesh"

    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20240801"
      size  = 10
      type  = "pd-balanced"
    }

    mode = "READ_WRITE"
  }

  can_ip_forward      = false
  deletion_protection = false
  enable_display      = false

  labels = {
    goog-ec-src = "vm_add-tf"
  }

  machine_type = "e2-micro"
  metadata = {
      startup-script = local.startup_script_content
  }

  name = "cd-webserver"

  scheduling {
    automatic_restart   = false
    preemptible         = false
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

  tags = ["http-server", "https-server", "ssh"]

  network_interface {
    network    = google_compute_network.vpc_network.self_link
    subnetwork = google_compute_subnetwork.subnet.self_link
    access_config {
      // Ephemeral IP
    }
  }
}
locals {
  startup_script_path = "startup-files/startup-script.sh"
  install_nginx_script_path = "startup-files/install-nginx.sh"
  startup_script_content = file(local.startup_script_path)
  install_nginx_script_content = file(local.install_nginx_script_path)
}