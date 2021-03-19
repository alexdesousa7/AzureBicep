variable "location" {
  type    = string
  default = "westeurope"
}
variable "prefix" {
  type    = string
  default = "AZTerraform"
}

variable "ssh-source-address" {
  type    = string
  default = "*"
}
