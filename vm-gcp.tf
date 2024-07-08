
resource "google_compute_instance" "default" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone
  project      = var.project

  tags = ["foo", "bar"]

  boot_disk {
    initialize_params {
      image = var.disk_image
      labels = {
        my_label = var.disk_label
      }
    }
  }

  // Local SSD disk
  scratch_disk {
    interface = var.interface_disk
  }

  network_interface {
    network = data.google_compute_network.vpc-prueba.id

    access_config {
      // Ephemeral public IP
    }
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.service_account.email
    scopes = ["cloud-platform"]
  }
}

resource "google_service_account" "service_account" {
  account_id   = var.account_id
  display_name = "Service Account"
  project      = var.project
}

data "google_compute_network" "vpc-prueba" {
  name = var.vpc_name
  project = var.project
}

