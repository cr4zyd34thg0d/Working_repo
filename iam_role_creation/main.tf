module "iam_role_creation" {
  source      = "./modules"                #update with source location
  role_name   = "AWSConfigRemediation"     #update with what you want the role name to be
  policy_name = "AWSAutoRemediationPolicy" #update with what you want the policy name to be
}