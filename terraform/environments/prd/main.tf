#########################################################
# Environment: PRD (Production)
#
# Deploy SCALE resources
#########################################################
terraform {
  backend "s3" {
    bucket         = "scale-terraform-state"
    key            = "ccs-scale-infra-services-shared-prd"
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
  environment = "PRD"
}

data "aws_ssm_parameter" "aws_account_id" {
  name = "account-id-${lower(local.environment)}"
}

module "deploy" {
  source                       = "../../modules/configs/deploy-all"
  aws_account_id               = data.aws_ssm_parameter.aws_account_id.value
  environment                  = local.environment
  agreements_cpu               = 1024
  agreements_memory            = 2048
  api_gw_log_retention_in_days = 30
  ecs_log_retention_in_days    = 30
}
