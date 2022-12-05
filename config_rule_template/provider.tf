terraform {
  required_version = "= 1.2.7"
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-west-2" #update with region to deploy terrform
}