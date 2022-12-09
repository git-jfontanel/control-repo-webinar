
variable "machines_count" {
    description = "The number of instances to build."
    default = 1
}

variable "pub_key" {
  description = "The public key name"
}

variable "location" {
    description = "The Azure location to build in."
    default = "ukwest"
}

variable "primary_ip" {
  description = "IP address primary Puppet server"
}

variable "primary_name" {
  description = "FQDM primary Puppet server"
  default     = "puppet.se.automationdemos.com"
}

variable "domain" {
  default = "cloudapp.azure.com"
}

variable "name" {
}

variable "os" {
  description = "The OS version to search for" 
}

variable "os_map_publisher" {
  description = "Map of publisher to search images"
  type        = map(string)
  default = {
    "ubuntu-18.04" = "Canonical"
    "ubuntu-20.04" = "Canonical"
  }
}

variable "os_map_sku" {
  description = "Map of sku to search images"
  type        = map(string)
  default     = {
    "ubuntu-18.04" = "minimal-18_04-daily-lts-gen2"
    "ubuntu-20.04" = "20_04-lts"
  }
}

variable "os_map_offer" {
  description = "Map of offer to search images"
  type        = map(string)
  default     = {
    "ubuntu-18.04" = "0002-com-ubuntu-minimal-bionic-daily"
    "ubuntu-20.04" = "0001-com-ubuntu-server-focal"
  }
}

variable "instance_type" {
  description = "The instance type to be provisioned"
}

variable "map_instance_type" {
  description = "Map of the instance type"
  type        = map(string)
  default     = {
    "Gold"   = "Standard_D2s_v3"
    "Silver" = "Standard_B2s"
    "Bronze" = "Standard_B1s"
  } 
}

variable "role" {
  description = "Role of the server for Puppet classification"
}

variable "challengepassword" {
  description = "Password used for autosigning of the Puppet agent"
}