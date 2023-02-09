# AWS Cloudwatch Terraform module

Terraform module which creates Cloudwatch resources on AWS. Fields for Loggroup need to be updated tot he ControlTower "AggregateSecurityNotifications" log group to work with the ControlTower CloudTrail.

## Usage

### Log metric filter

```hcl
module "log_metric_filter" {
  source  = "./modules/log-metric-filter"

  log_group_name = "-test"

  name    = "error-metric"
  pattern = "ERROR"

  metric_transformation_namespace = ""
  metric_transformation_name      = "ErrorCount"
  
    depends_on = [
    module.log_group
  ]
}
```

Read [Filter and Pattern Syntax](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/FilterAndPatternSyntax.html) for explanation of `pattern`.

### Log group

```hcl
module "log_group" {
  source  = "./modules/log-group"

  name              = "-test"
  retention_in_days = 365
}
```

### Log stream

```hcl
module "log_stream" {
  source  = "./modules/log-stream"

  name           = "-stream"
  log_group_name = "-test"

    depends_on = [
    module.log_group
  ]
}
```

### Metric alarm

```hcl
module "metric_alarm" {
  source  = "./modules/metric-alarm"

  alarm_name          = "-errors"
  alarm_description   = " alarms"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = 1
  period              = 60
  unit                = "Count"

  namespace   = ""
  metric_name = "ErrorCount"
  statistic = "Maximum"

  alarm_actions = ["arn:aws:sns:${data.aws_region.current.name}:${var.account_id}:-test"]
}
```

Check out [list of all AWS services that publish CloudWatch metrics](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/aws-services-cloudwatch-metrics.html) for detailed information about each supported service.

### CIS AWS Foundations Controls: Metrics + Alarms

```hcl
module "cis_alarms" {
  source  = "./modules/cis-alarms"
  namespace = "-cw-alarm"

  log_group_name = "-test"
  alarm_actions  = ["arn:aws:sns:${data.aws_region.current.name}:${var.account_id}:
  -test"]

      depends_on = [
    module.log_group
  ]
}
```

AWS CloudTrail normally publishes logs into AWS CloudWatch Logs. This module creates log metric filters together with metric alarms.

### SNS topic creation

```hcl
module "sns_topic" {
    source = "./modules/sns-topic"
    sns_name = "-test"
    account_id = "955305841756"
    protocol = "email"
    email = "UPDATE"
}
```

This module creates the SNS topic that the alrms will be tied to.

## Examples

- [Complete Cloudwatch log metric filter and alarm](https://github.com/terraform-aws-modules/terraform-aws-cloudwatch/tree/master/examples/complete-log-metric-filter-and-alarm)
- [Cloudwatch log group with log stream](https://github.com/terraform-aws-modules/terraform-aws-cloudwatch/tree/master/examples/log-group-with-log-stream)
- [Cloudwatch metric alarms for AWS Lambda](https://github.com/terraform-aws-modules/terraform-aws-cloudwatch/tree/master/examples/lambda-metric-alarm)
- [Cloudwatch metric alarms for AWS Lambda with multiple dimensions](https://github.com/terraform-aws-modules/terraform-aws-cloudwatch/tree/master/examples/metric-alarms-by-multiple-dimensions)
- [CIS AWS Foundations Controls: Metrics + Alarms](https://github.com/terraform-aws-modules/terraform-aws-cloudwatch/tree/master/examples/cis-alarms)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
