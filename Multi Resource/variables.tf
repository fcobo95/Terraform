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

variable "nsg_name" {
  description = "NSG name"
  type        = string
}

variable "vm_sku" {
  description = "Defines the VM's SKU type."
  type        = string
  default     = "Standard_D2s_v3"
}

variable "admin_password" {
  description = "Let TF request the plain text password for the VMs."
  type        = string
}

variable "number_of_vms" {
  description = "Set the value for the amount of VMs you want to deploy."
  type        = number
  default     = 1
}

variable "number_of_subnets" {
  description = "Set the value of the amount of subnets to be created."
  type        = number
  default     = 1
}

variable "key_vault_name" {
  description = "Set the name of the Key Vault to be created."
  type        = string
}
