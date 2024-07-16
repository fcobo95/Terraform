variable "resource_group" {
  description = "This is a variable used in TF to create a new resource group and kinda hide the name from the actual code and add it in the terrafom.tfvars file instead."
  type        = string
}

variable "location" {
  description = "Azure region in which we will deploy"
  type        = string
  default     = "westus"
}

variable "tags" {
  description = "Tags to be used and required by Azure Policy"
  type        = map(string)

  # This is one way if the Azure Policy requires just these specific tags always.

  #default = {
  #  "name" = "value"
  #}

  # This way, we can define the tags elsewhere, by using the map(string) object instead and setting default to null. 
  # For example, in the terraform.tfvars file we can define exactly which tags we want to use.

  #tags = {
  #    name = "abcd"
  #    usecase = "blabla"
  #    owner = "xyz@cloudera.com"
  #    env = "PROD"
  #    purpose = "CI/CD"
  #}

  default = null
}

variable "storage_name" {
  description = "Name of the storage account that will be created and used for storing data."
  type        = string
}

variable "storage_container_name" {
  description = "Name of the data container that will be created inside the storage account."
  type = string
}

variable "vnet_name" {
  description = "Name of the virtual network we will be creating."
  type = string
}