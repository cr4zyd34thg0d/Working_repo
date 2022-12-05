variable "config_rule_name" {
  description = "The name of the AWS Config instance."
  type        = string
}

variable "config_rule_description" {
  description = "The description of the AWS Config instance."
  type        = string
}

variable "config_rule_type" {
  description = "CUSTOM_LAMBDA or AWS."
  type        = string
  default     = "AWS"
}

variable "config_rule_source" {
  description = "SSM name or arn of custom Lambda."
  type        = string
}

variable "config_rule_input_parameters" {
  description = "Parameters for Config rule Lambda."
  type        = string
  default     = null
}

variable "config_role_name" {
  description = "The name of the role for use with config."
  type        = string
}

variable "config_logs_bucket" {
  description = "The name of the log bucket for use with config."
  type        = string
  default     = ""
}

variable "create_remediation" {
  description = "Boolean to determine if the remediation resource needs to be created."
  type        = bool
  default     = false
}

variable "remediation_resource_type" {
  description = "Resource types to be remediated. Usually follow a format like: AWS::ElasticLoadBalancing::LoadBalancer."
  type        = string
  default     = null
}

variable "remediation_target_type" {
  description = "Resource type performing remediation. Usually SSM_DOCUMENT."
  type        = string
  default     = "SSM_DOCUMENT"
}

variable "remediation_target_id" {
  description = "The name of the resource performing remediation. Usually the name of the SSM Document."
  type        = string
  default     = ""
}

variable "remediation_parameters" {
  description = "List of objects representing parameter name and value."
  type        = list(any)
  default     = []
}
