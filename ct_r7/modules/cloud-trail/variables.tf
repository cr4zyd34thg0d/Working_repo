variable "bucket_name" {
  type = string
}

variable "trail_name" {
  type = string
}


variable "tags" {
  description = "A map of tags (key-value pairs) passed to resources."
  type        = map(string)
}

variable "log_group_name" {
  type = string
}

variable "sns_topic_name" {
  type        = string
  description = "Name of sns topic shown in confirmation emails"
}

variable "sns_protocol" {
  description = "SNS Protocol to use. email or email-json or SQS"
  type        = string
}

variable "terraform_queue_name" {
  type        = string
  description = "Name of SQS"
}

variable "taccount_id" {
  type        = string
  description = "Account ID for policy"
}

variable "region" {
  type        = string
  description = "Name of region for deployment"
}