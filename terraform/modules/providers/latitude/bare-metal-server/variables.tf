variable "ssh_key_slug" {
  type = string
}

variable "project" {
  type = string
}

variable "os" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "c2-small-x86"
}

variable "hostname" {
  type    = string
  default = "sandbox-machine"
}

variable "region" {
  type    = string
  default = "SAO2"
}

variable "node_count" {
  type    = number
  default = 1
}

variable "tags" {
  type = list(string)

}
