#########################################################
# Environment: DEV
#
# Deploy SCALE resources
#########################################################
terraform {
  backend "s3" {
    bucket         = "scale-terraform-state"
    key            = "ccs-scale-infra-services-shared-dev"
    region         = "eu-west-2"
    dynamodb_table = "scale_terraform_state_lock"
    encrypt        = true
  }
}

provider "aws" {
  profile = "default"
  version = "~> 4.0.0"
  region  = "eu-west-2"
}

locals {
  environment = "DEV"
}

data "aws_ssm_parameter" "aws_account_id" {
  name = "account-id-${lower(local.environment)}"
}

module "deploy" {
  source         = "../../modules/configs/deploy-all"
  aws_account_id = data.aws_ssm_parameter.aws_account_id.value
  environment    = local.environment
}
