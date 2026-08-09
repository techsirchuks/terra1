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
