variable "dynamo_table_name" {
  type    = string
  default = ""
}

variable "creds_store" {
  type = string

  validation {
    condition     = contains(["secrets", "dynamo"], var.creds_store)
    error_message = "Allowed values for creds_store are \"secrets\" or \"dynamo\"."
  }
}
