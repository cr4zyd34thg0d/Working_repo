
variable "tags" {
  default     = {}
  description = "The tags to apply to resources created by this module"
  type        = map(string)
}

variable "sns_name" {
  description = "Name of the SNS Topic to be created"
  type        = string
}

variable "account_id" {
  description = "My Accout Number"
  type        = string
}

variable "protocol" {
  description = "protocol for sns"
  type        = string
  default     = "email"
}

variable "email" {
  description = "My Accout Number"
  type        = string
}