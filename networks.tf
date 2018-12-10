resource "google_compute_network" "networks" {
  count = "${length(var.office_locations)}"
  name  = "${var.office_locations[count.index]}"
}

resource "google_compute_subnetwork" "subnetworks" {
  count  = "${length(var.office_locations)}"

  network = "${var.office_locations[count.index]}"
  name    = "${var.subnet_names[var.office_locations[count.index]]}"
  region  = "${var.subnet_regions[var.office_locations[count.index]]}"
  
  ip_cidr_range = "${var.subnet_ips[var.subnet_names[var.office_locations[count.index]]]}"

  depends_on = ["google_compute_network.networks"]
}
