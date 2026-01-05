variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "my-terraform-rg"
}

variable "location" {
  description = "Azure region location"
  type        = string
  default     = "Central India"
}

variable "vm_size" {
  description = "Size of the Virtual Machine"
  type        = string
  default     = "Standard_B2ps_v2" # ARM processor size
}

variable "admin_username" {
  description = "Username for the VM"
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Password for the VM"
  type        = string
  sensitive   = true 
}