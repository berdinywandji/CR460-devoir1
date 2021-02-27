// Creation d'un compte de service.
resource "google_service_account" "mapaq1"{​​
account_id = "service_account_id"
display_name = "service_account"
}​​



// comment generer une clé
resource "google_service_account_key" "mykey"{​​
service_account_id = google_service_account.myaccount.name
public_key_type = "TYPE_X509_PEM_FILE"
}​​
