variable "secret_name" {
  description = "Name of the secret"
  type        = string
}

variable "description" {
  description = "Description of the secret"
  type        = string
  default     = ""
}

variable "secret_values" {
  description = "Key-value map to store as secret"
  type        = map(string)
}

variable "tags" {
  description = "Tags for the secret"
  type        = map(string)
  default     = {}
}
