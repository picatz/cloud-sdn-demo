resource "google_compute_instance" "vms" {
  count        = "${length(var.office_locations)}"
  name         = "${var.office_locations[count.index]}"
  machine_type = "f1-micro"	
  zone         = "${var.subnet_regions[var.office_locations[count.index]]}-b"

  boot_disk {
    initialize_params {
      image =  "ubuntu-os-cloud/ubuntu-1804-lts"
      size  = 10
    }
  }

  network_interface {
    subnetwork = "${var.subnet_names[var.office_locations[count.index]]}"

    access_config {
      // Ephemeral IP
    }
  }

  metadata {
    enable-oslogin = "TRUE"
  }
  
  depends_on = ["google_compute_subnetwork.subnetworks"]
}
