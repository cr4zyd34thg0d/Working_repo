module "global_iam" {
  source      = "./global_iam"
  role_name   = var.role_name
  policy_name = var.policy_name
}