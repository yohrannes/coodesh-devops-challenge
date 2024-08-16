provider "google" {}

#docker run -it -v $PWD:/root -w /root --entrypoint "" hashicorp/terraform:light sh

resource "google_compute_network" "vpc_network" {
  name                    = "vpc-coodesh"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "subnet-coodesh"
  ip_cidr_range = "10.0.0.0/24"
  network       = google_compute_network.vpc_network.self_link
}

resource "google_compute_firewall" "default-allow-http-https-ssh-icmp" {
  name        = "default-allow-http-https-ssh-icmp"
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
    startup-script = <<-EOF
      #!/bin/bash

      # Instalando docker engine e executando a aplicação em container.
      sudo apt-get update
      sudo apt-get install -y ca-certificates curl
      sudo install -m 0755 -d /etc/apt/keyrings
      sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
      sudo apt-get update
      sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
      sudo systemctl enable docker
      sudo systemctl start docker
      sudo docker run -d -p 5000:5000 yohrannes/coodesh-challenge

      # Instalando nginx como proxy da porta 80 para a 5000 da aplicação.
      sudo apt-get install -y nginx
      sudo tee /etc/nginx/sites-available/default > /dev/null <<NGINX_CONF
      server {
          listen 80;
          server_name _;

          location / {
              proxy_pass http://localhost:5000;
              proxy_set_header Host \$host;
              proxy_set_header X-Real-IP \$remote_addr;
              proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto \$scheme;
          }
      }
      NGINX_CONF
      sudo systemctl restart nginx
      sudo systemctl enable nginx

    EOF
  }

  name = "coodesh-webserver"

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
