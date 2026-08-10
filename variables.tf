variable "sub-id" {
    description = "The decoy name of our subscription_id"
    type = string
    sensitive = true
}

variable "terra-rg"{
    description = "The decoy name of our rg"
    type = string
    default = "terra1"
}

variable "location" {
    description = "The decoy name of our location"
    type = string
    default = "southafricanorth"
}

variable "vnet-name" {
    description = "The decoy name of the vnet"
    type = string
    default = "terra1-vnet"
}

variable "vnet-address" {
    description = "The decoy address of our vnet"
    type = list (string)
    default = ["10.0.0.0/16"]
}

variable "snet-name" {
description = "THe decoy name of our subnet"
type = string
default = "terra1-subnet"
}

variable "snet-address" {
description = "THe decoy name of our subnet"
type = list (string)
default = ["10.0.1.0/24"]
}