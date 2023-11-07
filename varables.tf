variable "deploy_location" {
  default     = "North Europe"
  description = "Location of the resource group."
}
variable "rfc3339" {
  default     = "2023-12-06T12:43:13Z"
  description = "token expiration"

}
variable "rg" {
  type        = string
  default     = "FFIonline"
  description = "Name of the Resource group in which to deploy session host"
}

variable "rdsh_count" {
  description = "Number of AVD machines to deploy"
  default     = 2
}

variable "prefix" {
  type        = string
  default     = "FFIa"
  description = "Prefix of the name of the AVD machine(s)"
}

variable "vm_size" {
  description = "Size of the machine to deploy"

}

variable "local_admin_username" {
  type        = string
  default     = "localadm"
  description = "local admin username"
}
variable "Hostpoolname" {
  type        = string
  description = "hostpoolname"
}
variable "MaskinNavn" {
  type        = string
  description = "MaskinNavn"
}

variable "Domeneresurs" {
  type = string
  description = "navn på resursgruppe med managed domain"
  }

  variable "ffionlinepoolnet"{
    type = string
    description = "Navn på prodnet"
  }

  variable "onlinepoolsubnet01"{
    type = string
    description = "prodsubnet"
  }

  variable "tilaad"{
     type = string
     description = "pering fra prod til ad"
  }