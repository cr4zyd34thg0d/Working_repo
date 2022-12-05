variable "sns_topic_name" {
  type        = string
  description = "Name of sns topic"
}

variable "sns_protocol" {
  description = "SNS Protocol to use. email or email-json or SQS"
  type        = string
  default     = "sqs"
}

variable "terraform_queue_name" {
  type        = string
  description = "Name of SQS"
  default     = "S3BucketPolicyChanges" #change name for naming convention for SQS
}