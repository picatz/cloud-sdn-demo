// https://www.terraform.io/docs/providers/google/r/compute_network.html

variable "office_locations" {
  type    = "list"
  default = ["ohio", "california", "texas"]
}

variable "subnet_regions" {
  type    = "map"
  default = {
    "ohio"       = "us-east1"
    "california" = "us-west1"
    "texas"      = "us-central1"
  }
}

variable "subnet_names" {
  type    = "map"
  default = {
    "ohio"       = "hq"
    "california" = "satelite"
    "texas"      = "warehouse"
  }
}

variable "subnet_ips" {
  type    = "map"
  default = {
    "hq"        = "10.5.4.0/24"
    "satelite"  = "10.4.2.0/24"
    "warehouse" = "10.1.3.0/24"
  }
}
