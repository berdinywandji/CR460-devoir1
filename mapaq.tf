resource "google_service_account" "mapaq" {
  account_id = "${var.account_id}"
  project    = "${var.project_id}"
}

resource "google_service_account_key" "mapaq" {
  service_account_id = "${google_service_account.mapaq.name}"
}

data "google_service_account_key" "mapaq" {
  name            = "${google_service_account_key.cd.name}"
  public_key_type = "TYPE_X509_PEM_FILE"
}


/*resource "google_service_account" "my-account" {
  account_id = "${var.account_id}"
  project    = "${var.project_id}"
}

resource "google_service_account_key" "my-account" {
  service_account_id = "${google_service_account.my-account.name}"
}

resource "local_file" "key" {
  filename = "/path/to/key/output"
  content  = "${base64decode(google_service_account_key.my-account.private_key)}"
}*/
