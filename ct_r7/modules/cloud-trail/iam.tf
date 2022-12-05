resource "aws_iam_role" "cloudtrail_role" {
  name               = "cloudtrail-role"
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_assume_policy.json
}

resource "aws_iam_policy" "cloudtrail_access_policy" {
  name   = "cloudtrail-policy"
  policy = data.aws_iam_policy_document.cloudtrail_policy.json
}

resource "aws_iam_policy_attachment" "cloudtrail_access_policy_attachment" {
  name       = "cloudtrail-policy-attachment"
  policy_arn = aws_iam_policy.cloudtrail_access_policy.arn
  roles      = ["${aws_iam_role.cloudtrail_role.name}"]
}