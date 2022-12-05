
variable "tags" {
  default     = {}
  description = "The tags to apply to resources created by this module."
  type        = map(string)
}

variable "sns_name" {
  description = "Name of the SNS Topic to be created."
  type        = string
}

variable "account_id" {
  description = "My account number."
  type        = string
}

variable "protocol" {
  description = "Protocol for sns."
  type        = string
  default     = "email"
}

variable "email" {
  description = "Email to subscribe to topic."
  type        = list(string)
}