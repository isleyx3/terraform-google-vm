
variable "project_id" {
  type        = string
  description = "The ID of the project where this VPC will be created"
}

variable "network" {
  type        = string
  description = "The name of VPC being created"
}

variable "region" {
  type        = string
  description = "The region in which you want to create the VPN gateway"
}

variable "shared_secret" {
  type        = string
  description = "Please enter the shared secret/pre-shared key"
  default     = ""
}

variable "ip_ranges" {
type = map(string)
description = "Ranges GCP"
}