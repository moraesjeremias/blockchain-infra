variable "project" {
  type = string
}

variable "region" {
  type    = string
  default = "SAO2"
}

variable "vlan_description" {
  type    = string
  default = "Virtual Network description"
}

variable "server_ids" {
  type = map(string)
}

variable "tags" {
  type = list(string)

}
