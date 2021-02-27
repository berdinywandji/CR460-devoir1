resource "google_compute_instance" "canard" {
  name         = "canard"
  machine_type = "f1-micro"
  zone         = "us-east1-c"
  tags         = ["public"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.prod-dmz.name
    access_config {

    }
  }


  metadata_startup_script = "apt-get -y update && apt-get -y upgrade && apt-get -y install apache2 && systemctl start apache2"
}


resource "google_compute_instance" "mouton" {
  name         = "mouton"
  machine_type = "f1-micro"
  zone         = "us-east1-c"
  tags         = ["public"]

  boot_disk {
    initialize_params {
      image = "fedora-coreos-cloud/fedora-coreos-stable"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.prod-interne.name
    access_config {

    }
  }
}


resource "google_compute_instance" "fermier" {
  name         = "fermier"
  machine_type = "f1-micro"
  zone         = "us-east1-c"
  tags         = ["workload"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1604-lts"
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.prod-traitement.name

  }
}

resource "google_compute_instance" "etcd1" {
  name         = "etcd1"
  machine_type = "f1-micro"
  zone         = "us-east1-c"
  tags         = ["backend"]

  boot_disk {
    initialize_params {
      image = "fedora-coreos-cloud/fedora-coreos-stable"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.mtl-backend.name

  }
}

  resource "google_compute_instance" "etcd2" {
    name         = "etcd2"
    machine_type = "f1-micro"
    zone         = "us-east1-c"
    tags         = ["backend"]

    boot_disk {
      initialize_params {
        image = "fedora-coreos-cloud/fedora-coreos-stable"
      }
    }

    network_interface {
      subnetwork = google_compute_subnetwork.mtl-backend.name
    }
}

    resource "google_compute_instance" "etcd3" {
      name         = "etcd3"
      machine_type = "f1-micro"
      zone         = "us-east1-c"
      tags         = ["backend"]

      boot_disk {
        initialize_params {
          image = "fedora-coreos-cloud/fedora-coreos-stable"
        }
      }

      network_interface {
        subnetwork = google_compute_subnetwork.mtl-backend.name

      }
}


resource "google_compute_instance_template" "cr460-cheval-template" {
  name                 = "cr460-cheval-template"
  tags                 = ["workload"]
  machine_type         = "n1-standard-1"
  region               = "us-east1"
  can_ip_forward       = true

  // Create a new boot disk from an image
  disk {
    source_image = "fedora-coreos-cloud/fedora-coreos-stable"
    auto_delete = true
    boot = false
  }

  network_interface {
    subnetwork = google_compute_subnetwork.prod-traitement.name
    access_config {

    }
  }

}

resource "google_compute_instance_group_manager" "cr460-workload-gm" {
  name        = "cr460-workload-gm"
  base_instance_name = "cheval"
  version {
    instance_template  = google_compute_instance_template.cr460-cheval-template.self_link
    name               = "primary"
  }
  zone               = "us-east1-c"

}

resource "google_compute_autoscaler" "cr460-autoscaler" {
  name   = "cr460-autoscaler"
  zone   = "us-east1-c"
  target = google_compute_instance_group_manager.cr460-workload-gm.self_link

  autoscaling_policy {
    max_replicas    = 6
    min_replicas    = 1
    cooldown_period = 60

    cpu_utilization {
      target = 0.77
    }
  }
}
/*resource "google_compute_autoscaler" "cr460-autoscaler" {
  name   = "cr460-autoscaler"
  zone   = "us-east1-c"
  target = google_compute_instance_group_manager.cr460-workload-gm.self_link

  autoscaling_policy = {
    max_replicas    = 5
    min_replicas    = 2
    cooldown_period = 60

    cpu_utilization {
      target = 0.5
    }
  }
}*/
