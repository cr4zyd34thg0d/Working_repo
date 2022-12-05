module "log_metric_filter" {
  source = "./modules/log-metric-filter" #Source Location

  log_group_name = "aws-controltower/CloudTrailLogs" #Log Group Nmae

  name    = "error-metric" #Error Metric name
  pattern = "ERROR"

  metric_transformation_namespace = "auction" #Metric namespace
  metric_transformation_name      = "ErrorCount"

}

module "log_stream" {
  source = "./modules/log-stream" #source Location

  name           = "auction-stream"                  #Log Stream Name
  log_group_name = "aws-controltower/CloudTrailLogs" #Log Group Name

}

module "metric_alarm" {
  source = "./modules/metric-alarm" #Source Location

  alarm_name          = "auction-errors" #Metric Alarm Name
  alarm_description   = "auction alarms" #Alarm Descritpion
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1  #How many times to evaluate the alarm
  threshold           = 1  #How many findings is allowed
  period              = 60 #period of 60 seconds
  unit                = "Count"

  namespace   = "auction" #Namespace
  metric_name = "ErrorCount"
  statistic   = "Maximum"

  alarm_actions = ["arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:auction-cw-alarm"]

  depends_on = [
    module.sns_topic
  ]
}

module "cis_alarms" {
  source    = "./modules/cis-alarms" #Source Location
  namespace = "auction-cw-alarm"     #Namespace for Alarms

  log_group_name = "aws-controltower/CloudTrailLogs" #log group name
  alarm_actions  = ["arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:auction-cw-alarm"]

  depends_on = [
    module.sns_topic
  ]
}

module "sns_topic" {
  source     = "./modules/sns-topic" #Source Location
  sns_name   = "auction-cw-alarm"    #SNS topic name
  account_id = data.aws_caller_identity.current.account_id
  protocol   = "email" #Security Email address
}