resource "google_compute_firewall" "allow_icmp_and_ssh" {
  count   = "${length(var.office_locations)}"
  
  name    = "allow-icmp-and-ssh-${var.office_locations[count.index]}"
  network = "${var.office_locations[count.index]}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  
  depends_on = ["google_compute_network.networks"]
}
