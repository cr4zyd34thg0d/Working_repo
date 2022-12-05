// Add ability to "turn on and off" specific config rules
variable "role_name" {
  description = "The name of the IAM role."
  type        = string
  default     = "AWSConfigRemediation"
}

variable "policy_name" {
  description = "The name of the IAM role policy."
  type        = string
  default     = "AWSAutoRemediationPolicy"
}