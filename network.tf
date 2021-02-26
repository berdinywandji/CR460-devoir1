resource "google_compute_network" "devoir1" {
  name                    = "devoir1"
  auto_create_subnetworks = "false"
}


resource "google_compute_subnetwork" "prod-dmz" {
  name          = "prod-dmz"
  ip_cidr_range = "192.168.42.0/24"
  region        = "us-east1"
  network       = google_compute_network.devoir1.self_link
}

resource "google_compute_subnetwork" "prod-traitement" {
  name          = "prod-traitement"
  ip_cidr_range = "10.0.46.0/24"
  network       = google_compute_network.devoir1.self_link
  region        = "us-east1"
}

resource "google_compute_subnetwork" "prod-interne" {
  name          = "prod-interne"
  ip_cidr_range = "172.16.5.0/24"
  region        = "us-east1"
  network       = google_compute_network.devoir1.self_link
}

resource "google_compute_subnetwork" "mtl-backend" {
  name          = "mtl-backend"
  ip_cidr_range = "10.0.3.0/24"
  network       = google_compute_network.devoir1.self_link
  region        = "us-east1"
}


resource "google_compute_firewall" "ssh-public" {
  name    = "ssh-public"
  network = google_compute_network.devoir1.name
  allow {
    protocol = "tcp"
    ports    = ["1521", "3368"]
  }
  target_tags=["public"]
}

resource "google_compute_firewall" "web-public" {
  name    = "web-public"
  network = google_compute_network.devoir1.name
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  target_tags=["public"]
}

resource "google_compute_firewall" "ssh-workload" {
  name    = "ssh-workload"
  network = google_compute_network.devoir1.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  target_tags=["workload"]
}

resource "google_compute_firewall" "internal-control" {
  name    = "internal-control"
  network = google_compute_network.devoir1.name

  allow {
    protocol = "tcp"
    ports    = ["22", "2379", "2380"]
  }

  source_ranges = ["192.168.42.0/24", "10.0.46.0/24" ]
  target_tags = ["backend"]
}


/*resource "google_dns_record_set" "jump" {
  name = "jump.cloudlab.matbilodeau.dev."
  type = "A"
  ttl  = 300

  managed_zone = "cloudlab"

  rrdatas = [google_compute_instance.canard.network_interface.0.access_config.0.nat_ip]
}


resource "google_dns_record_set" "vault" {
  name = "vault.cloudlab.matbilodeau.dev."
  type = "A"
  ttl  = 300

  managed_zone = "cloudlab"

  rrdatas = [google_compute_instance.mouton.network_interface.0.access_config.0.nat_ip]
}*/
