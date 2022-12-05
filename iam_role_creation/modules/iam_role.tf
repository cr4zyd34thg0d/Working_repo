resource "aws_iam_role" "r" {
  name = var.role_name

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "p" {
  name = var.policy_name
  role = aws_iam_role.r.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Action": [ 
          "ssm:StartAutomationExecution",
          "ssm:GetAutomationExecution",
          "ssm:UpdateServiceSetting",
          "lambda:InvokeFunction",
          "elasticloadbalancing:DescribeLoadBalancingAttributes",
          "elasticloadbalancing:ModifyLoadBalancingAttributes",
          "ec2:*",
          "logs:PutRetentionPolicy",
          ],

          "Effect": "Allow",
          "Resource": "*" 

      }
  ]
}
POLICY 
} #adjust to specific resource(s)
