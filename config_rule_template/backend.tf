terraform {

  backend "s3" {
    region         = "<region_of_bucket>"
    bucket         = "<bucket_name>"
    key            = "<name_of_state_file>"
    dynamodb_table = "adc-sre-terraform-state-lock"
  }
}