resource "google_compute_vpn_gateway" "gateways" {
  count   = "${length(var.office_locations)}"
  network = "${var.office_locations[count.index]}"
  region  = "${var.subnet_regions[var.office_locations[count.index]]}"
  name    = "${var.office_locations[count.index]}"
  
  depends_on = ["google_compute_network.networks"]
}

resource "google_compute_address" "vpn_static_ip" {
  count   = "${length(var.office_locations)}"
  name    = "${var.office_locations[count.index]}"
  region  = "${var.subnet_regions[var.office_locations[count.index]]}"
}

resource "google_compute_forwarding_rule" "fr_esp" {
  count       = "${length(var.office_locations)}"
  name        = "${var.office_locations[count.index]}-fr-esp"
  ip_protocol = "ESP"
  ip_address  = "${google_compute_address.vpn_static_ip.*.address[count.index]}"
  target      = "${google_compute_vpn_gateway.gateways.*.self_link[count.index]}"
  region      = "${var.subnet_regions[var.office_locations[count.index]]}"
}

resource "google_compute_forwarding_rule" "fr_udp500" {
  count       = "${length(var.office_locations)}"
  name        = "${var.office_locations[count.index]}-fr-udp500"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = "${google_compute_address.vpn_static_ip.*.address[count.index]}"
  target      = "${google_compute_vpn_gateway.gateways.*.self_link[count.index]}"
  region      = "${var.subnet_regions[var.office_locations[count.index]]}"
}

resource "google_compute_forwarding_rule" "fr_udp4500" {
  count       = "${length(var.office_locations)}"
  name        = "${var.office_locations[count.index]}-fr-udp4500"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = "${google_compute_address.vpn_static_ip.*.address[count.index]}"
  target      = "${google_compute_vpn_gateway.gateways.*.self_link[count.index]}"
  region      = "${var.subnet_regions[var.office_locations[count.index]]}"
}

// east <--> west

resource "google_compute_vpn_tunnel" "east_to_west" {
  name          = "east-to-west"
  region        = "${var.subnet_regions[var.office_locations[0]]}"
  peer_ip       = "${google_compute_address.vpn_static_ip.*.address[1]}"
  shared_secret = "supersecretpassword123"

  target_vpn_gateway = "${google_compute_vpn_gateway.gateways.*.self_link[0]}"

  local_traffic_selector  = ["0.0.0.0/0"]
  remote_traffic_selector = ["0.0.0.0/0"]

  depends_on = [
    "google_compute_forwarding_rule.fr_esp",
    "google_compute_forwarding_rule.fr_udp500",
    "google_compute_forwarding_rule.fr_udp4500",
  ]
}

resource "google_compute_vpn_tunnel" "west_to_east" {
  name          = "west-to-east"
  region        = "${var.subnet_regions[var.office_locations[1]]}"
  peer_ip       = "${google_compute_address.vpn_static_ip.*.address[0]}"
  shared_secret = "supersecretpassword123"

  target_vpn_gateway = "${google_compute_vpn_gateway.gateways.*.self_link[1]}"

  local_traffic_selector  = ["0.0.0.0/0"]
  remote_traffic_selector = ["0.0.0.0/0"]
  
  depends_on = [
    "google_compute_forwarding_rule.fr_esp",
    "google_compute_forwarding_rule.fr_udp500",
    "google_compute_forwarding_rule.fr_udp4500",
  ]
}

resource "google_compute_route" "east_to_west" {
  name       = "east-to-west"
  network    = "${var.office_locations[0]}"
  dest_range = "${var.subnet_ips[var.subnet_names[var.office_locations[1]]]}"

  next_hop_vpn_tunnel = "${google_compute_vpn_tunnel.east_to_west.self_link}"
}

resource "google_compute_route" "west_to_east" {
  name       = "west-to-east"
  network    = "${var.office_locations[1]}"
  dest_range = "${var.subnet_ips[var.subnet_names[var.office_locations[0]]]}"

  next_hop_vpn_tunnel = "${google_compute_vpn_tunnel.west_to_east.self_link}"
}

// east <--> central

resource "google_compute_vpn_tunnel" "east_to_central" {
  name          = "east-to-central"
  region        = "${var.subnet_regions[var.office_locations[0]]}"
  peer_ip       = "${google_compute_address.vpn_static_ip.*.address[2]}"
  shared_secret = "supersecretpassword123"

  target_vpn_gateway = "${google_compute_vpn_gateway.gateways.*.self_link[0]}"

  local_traffic_selector  = ["0.0.0.0/0"]
  remote_traffic_selector = ["0.0.0.0/0"]

  depends_on = [
    "google_compute_forwarding_rule.fr_esp",
    "google_compute_forwarding_rule.fr_udp500",
    "google_compute_forwarding_rule.fr_udp4500",
  ]
}

resource "google_compute_vpn_tunnel" "central_to_east" {
  name          = "central-to-east"
  region        = "${var.subnet_regions[var.office_locations[2]]}"
  peer_ip       = "${google_compute_address.vpn_static_ip.*.address[0]}"
  shared_secret = "supersecretpassword123"

  target_vpn_gateway = "${google_compute_vpn_gateway.gateways.*.self_link[2]}"

  local_traffic_selector  = ["0.0.0.0/0"]
  remote_traffic_selector = ["0.0.0.0/0"]
  
  depends_on = [
    "google_compute_forwarding_rule.fr_esp",
    "google_compute_forwarding_rule.fr_udp500",
    "google_compute_forwarding_rule.fr_udp4500",
  ]
}

resource "google_compute_route" "east_to_central" {
  name       = "east-to-central"
  network    = "${var.office_locations[0]}"
  dest_range = "${var.subnet_ips[var.subnet_names[var.office_locations[2]]]}"

  next_hop_vpn_tunnel = "${google_compute_vpn_tunnel.east_to_central.self_link}"
}

resource "google_compute_route" "central_to_east" {
  name       = "central-to-east"
  network    = "${var.office_locations[2]}"
  dest_range = "${var.subnet_ips[var.subnet_names[var.office_locations[0]]]}"

  next_hop_vpn_tunnel = "${google_compute_vpn_tunnel.central_to_east.self_link}"
}

// central <--> west

// resource "google_compute_vpn_gateway" "california" {
//   network = "california"
//   region  = "us-west1"
//   name    = "california-cr"
// }
// 
// resource "google_compute_vpn_gateway" "texas" {
//   network = "texas"
//   region  = "us-central1"
//   name    = "texas-cr"
// }
// 
// resource "google_compute_address" "california" {
//   name    = "california-cr"
//   region  = "us-west1"
// }
// 
// resource "google_compute_address" "texas" {
//   name    = "texas-cr"
//   region  = "us-central1"
// }
// 
// resource "google_compute_vpn_tunnel" "california" {
//   name          = "california-cr"
//   peer_ip       = "${google_compute_address.texas.address}"
//   shared_secret = "supersecretpassword123"
// 
//   target_vpn_gateway = "${google_compute_vpn_gateway.california.self_link}"
// 
//   router = "${google_compute_router.california.name}"
// 
//   depends_on = [
//     "google_compute_forwarding_rule.fr_esp",
//     "google_compute_forwarding_rule.fr_udp500",
//     "google_compute_forwarding_rule.fr_udp4500",
//   ]
// }
// 
// resource "google_compute_vpn_tunnel" "texas" {
//   name          = "texas-cr"
//   peer_ip       = "${google_compute_address.california.address}"
//   shared_secret = "supersecretpassword123"
// 
//   target_vpn_gateway = "${google_compute_vpn_gateway.texas.self_link}"
// 
//   router = "${google_compute_router.texas.name}"
// 
//   depends_on = [
//     "google_compute_forwarding_rule.fr_esp",
//     "google_compute_forwarding_rule.fr_udp500",
//     "google_compute_forwarding_rule.fr_udp4500",
//   ]
// }



// outputs

output "vpn_gateway_addresses" {
  value = "${google_compute_address.vpn_static_ip.*.address}"
}
