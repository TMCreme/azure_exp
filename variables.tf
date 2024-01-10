variable "prefix" {
  default = "tfvmex"
}

variable "admin_username" {
  default = "testadmin"
}

variable "admin_password" {
  default = "Password1234!"
}

variable "computer_name" {
  default = "hostname"
}

variable "subscription_id" {
  type    = string
  default = ""
}

variable "tenant_id" {
  type    = string
  default = ""
}

variable "client_id" {
  type    = string
  default = ""
}

variable "client_secret" {
  type    = string
  default = ""
}
