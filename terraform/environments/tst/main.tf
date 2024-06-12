#########################################################
# Environment: TST (User Acceptance Testing)
#
# Deploy SCALE resources
#########################################################
terraform {
  backend "s3" {
    bucket         = "scale-terraform-state"
    key            = "ccs-scale-infra-services-shared-tst"
    region         = "eu-west-2"
    dynamodb_table = "scale_terraform_state_lock"
    encrypt        = true
    role_arn       = "arn:aws:iam::016776319009:role/scale-terraform-state-role"
  }
}

provider "aws" {
  #profile = "default"
  version = "~> 4.0.0"
  region  = "eu-west-2"
}

locals {
  environment = "TST"
}

#data "aws_ssm_parameter" "aws_account_id" {
#  name = "account-id-${lower(local.environment)}"
#}

data "aws_caller_identity" "current" {}

module "deploy" {
  source                  = "../../modules/configs/deploy-all"
  aws_account_id          = data.aws_caller_identity.current.account_id
  environment             = local.environment
  ecr_image_id_agreements = var.ecr_image_id_agreements
  cognito_user_pool_arn   = var.cognito_user_pool_arn
}
