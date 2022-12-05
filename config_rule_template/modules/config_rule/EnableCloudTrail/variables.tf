variable "config_name" {
  description = "The name of the AWS Config instance."
  type        = string
}

variable "config_aggregator_name" {
  description = "The name of the aggregator."
  type        = string
}

variable "config_recorder_name" {
  description = "The name of the AWS Config recorder instance."
  type        = string
}

variable "enable_config_recorder" {
  description = "Enables configuring the AWS Config recorder resources in this module."
  type        = bool
  default     = true
}

variable "config_delivery_frequency" {
  description = "The frequency with which AWS Config delivers configuration snapshots."
  default     = "Six_Hours"
  type        = string
}

variable "config_logs_bucket" {
  description = "The S3 bucket for AWS Config logs. If you have set enable_config_recorder to false then this can be an empty string."
  type        = string
}

variable "check_config" {
  description = "Enable s3-bucket-versioning"
  type        = bool
  default     = true
}

# variable "remediation_resource_type" {
#   description = "The resource type for the remediation"
#   type        = string
# }

# variable "remediation_target_type" {
#   description = "The target type (SSM Document) type for the remediation"
#   type        = string
# }

# variable "remediation_target_id" {
#   description = "The target id type for the remediation"
#   type        = string
# }

variable "config_role_name" {
  description = "The name of the role for use with config"
  type        = string
}

variable "config_delivery_name" {
  description = "The name of the delivery channel name for use with config"
  type        = string
}

variable "rule_source" {
  description = "The name of the rule from AWS"
  type        = string
}

variable "config_role_arn" {
  description = "The name of the rule from AWS"
  type        = string
}