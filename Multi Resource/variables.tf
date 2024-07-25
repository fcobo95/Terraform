variable "storage_account_name" {
  description = "Storage account given name."
  type        = string
}

variable "location" {
  description = "Azure region to be used for the deployment."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the deployment's resource group."
  type        = string
}

variable "tags" {
  description = "Tags for the deployment and resources to be created."
  type        = map(string)
}

variable "owner" {
  description = "Name of the deployment's owner."
  type        = string
}

variable "vnet_name" {
  description = "Name of the Virtual Network"
  type        = string
}

variable "address_space" {
  description = "The Virtual Network's address space for subnetting."
  type        = string
  default     = "10.101.0.0/16"
}

variable "number_of_subnets" {
  description = "The numeric value of the amount of subnets you want to create"
  type        = number
  default     = 2
}
