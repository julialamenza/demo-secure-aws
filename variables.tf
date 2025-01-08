# variables.tf
variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-west-2"
}

variable "access_key" {
  description = "AWS Access Key"
  type        = string
  sensitive   = true
}

variable "secret_key" {
  description = "AWS Secret Key"
  type        = string
  sensitive   = true
}
