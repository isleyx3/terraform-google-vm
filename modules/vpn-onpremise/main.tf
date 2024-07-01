# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

/******************************************
           MODULE VPN GCP 
 *****************************************/

provider "google" {
  project     = var.project_id
  region      = var.region
}

resource "google_compute_ha_vpn_gateway" "ha_gateway" {
  region   = var.region
  name     = "vpn-onpremise"
  network  = "projects/${var.project_id}/global/networks/${var.network}"
}

resource "google_compute_external_vpn_gateway" "external_gateway" {
  name            = "gw-vpn"
  redundancy_type = "SINGLE_IP_INTERNALLY_REDUNDANT"
  interface {
    id         = 0
    ip_address = "190.96.73.50"
  }
}

resource "google_compute_router" "router1" {
  name     = "router-vpn"
  network  = "projects/${var.project_id}/global/networks/${var.network}"
  bgp {
    asn = 64512
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
    advertised_ip_ranges {
      range = "10.2.0.0/16"
      description = "intervalo-completo-10-2" 
    }
  }
}

resource "google_compute_vpn_tunnel" "tunnel1" {
  name                            = "gcp-to-onprem-cisco-prod"
  region                          = var.region
  vpn_gateway                     = google_compute_ha_vpn_gateway.ha_gateway.id
  peer_external_gateway           = google_compute_external_vpn_gateway.external_gateway.id
  peer_external_gateway_interface = 0
  shared_secret                   = "[INGRESAR PRE SHARED KEY]"
  router                          = google_compute_router.router1.id
  vpn_gateway_interface           = 0
}

resource "google_compute_router_interface" "router1_interface1" {
  name       = "router1-interface1"
  router     = google_compute_router.router1.name
  region     = var.region
  ip_range   = "169.254.0.1/30"
  vpn_tunnel = google_compute_vpn_tunnel.tunnel1.name
}

resource "google_compute_router_peer" "router1_peer1" {
  name                      = "router1-peer1"
  router                    = google_compute_router.router1.name
  region                    = var.region
  peer_ip_address           = "169.254.0.2"
  peer_asn                  = 65500
  advertised_route_priority = 200
  interface                 = google_compute_router_interface.router1_interface1.name
}
