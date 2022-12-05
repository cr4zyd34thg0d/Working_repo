module "cloudtrail" {
  source               = "./modules/cloud-trail"
  terraform_queue_name = "testingpolicyfortestest"
  sns_topic_name       = "testingpolicyfortestest"
  sns_protocol         = "sqs"
  bucket_name          = "testingpolicyfortestest"
  trail_name           = "testingpolicyfortestest"
  log_group_name       = "testingpolicyfortestest"
  region               = "us-west-2"
  account_id           = "955305841756"
  tags = {
    "Workload Name"         = "" #Update with tag name (add confluence link to mandatory tags)
    "Application Name"      = "" #Update with tag name (add confluence link to mandatory tags)
    "Environment"           = "" #Update with tag name (add confluence link to mandatory tags)
    "Business Unit"         = "" #Update with tag name (add confluence link to mandatory tags)
    "Operations Commitment" = "" #Update with tag name (add confluence link to mandatory tags)
    "Operations Team"       = "" #Update with tag name (add confluence link to mandatory tags)
    "Business Criticality"  = "" #Update with tag name (add confluence link to mandatory tags)
    "Data Classification"   = "" #Update with tag name (add confluence link to mandatory tags)
    "Disaster Recovery"     = "" #Update with tag name (add confluence link to mandatory tags)
  }
}