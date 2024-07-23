variable "resource_group_location" {
  type        = string
  default     = "eastus"
  description = "Local do grupo de recursos"
}

variable "resource_group_name" {
  type        = string
  default     = "student-rg"
  description = "Nome para o grupo de recursos."
}

variable "vm_admin_username" {
  type        = string
  description = "O usuario que vai ser utilizado pra acessar a VM."
  default     = "azureuser"
}

variable "vm_admin_password" {
  type        = string
  description = "Senha do usuario que vai ser utilizado pra acessar a VM."
}