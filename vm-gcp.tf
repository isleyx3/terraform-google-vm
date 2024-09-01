
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
    subnetwork = data.google_compute_subnetwork.teste-sub.id

    access_config {
      // Ephemeral public IP
    }
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = data.google_service_account.cuenta-prueba.email
    scopes = ["cloud-platform"]
  }
}

data "google_service_account" "cuenta-prueba" {
  account_id = "prueba-vm@bx-icloud-sandbox.iam.gserviceaccount.com"
}

data "google_compute_network" "vpc-prueba" {
  name = var.vpc_name
  project = var.project
}

data "google_compute_subnetwork" "teste-sub" {
  project = var.project
  name   = "test-subnetwork"
  region = "us-central1"
}

#nada
