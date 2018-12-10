resource "google_compute_router" "california" {
  name    = "california"
  network = "california"
  region  = "us-west1"
  
  bgp {
    asn = 65470
  }
  
  depends_on = ["google_compute_network.networks"]
}

resource "google_compute_router" "texas" {
  name    = "texas"
  network = "texas"
  region  = "us-central1"
  
  bgp {
    asn = 65503
  }
  
  depends_on = ["google_compute_network.networks"]
}
