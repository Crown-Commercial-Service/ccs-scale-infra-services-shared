#########################################################
# Config: deploy-all
#
# This configuration will deploy all components.
#########################################################
provider "aws" {
  profile = "default"
  region  = "eu-west-2"

  assume_role {
    role_arn = "arn:aws:iam::${var.aws_account_id}:role/CCS_SCALE_Build"
  }
}

data "aws_ssm_parameter" "vpc_id" {
  name = "${lower(var.environment)}-vpc-id"
}

data "aws_ssm_parameter" "private_app_subnet_ids" {
  name = "${lower(var.environment)}-private-app-subnet-ids"
}

data "aws_ssm_parameter" "private_db_subnet_ids" {
  name = "${lower(var.environment)}-private-db-subnet-ids"
}

data "aws_ssm_parameter" "vpc_link_id" {
  name = "${lower(var.environment)}-vpc-link-id"
}

data "aws_ssm_parameter" "lb_public_arn" {
  name = "${lower(var.environment)}-lb-public-arn"
}

data "aws_ssm_parameter" "lb_private_arn" {
  name = "${lower(var.environment)}-lb-private-arn"
}

data "aws_ssm_parameter" "lb_private_dns" {
  name = "${lower(var.environment)}-lb-private-dns"
}

data "aws_ssm_parameter" "agreements_db_endpoint" {
  name = "${lower(var.environment)}-agreements-db-endpoint"
}

data "aws_ssm_parameter" "agreements_db_username" {
  name = "${lower(var.environment)}-agreements-db-master-username"
}

data "aws_ssm_parameter" "agreements_db_password" {
  name = "${lower(var.environment)}-agreements-db-master-password"
}

data "aws_ssm_parameter" "cidr_block_vpc" {
  name = "${lower(var.environment)}-cidr-block-vpc"
}

module "ecs" {
  source          = "../../ecs"
  vpc_id          = data.aws_ssm_parameter.vpc_id.value
  environment     = var.environment
  cidr_block_vpc  = data.aws_ssm_parameter.cidr_block_vpc.value
}

module "api" {
  source      = "../../api"
  environment = var.environment
}

module "agreements" {
  source                       = "../../services/agreements"
  environment                  = var.environment
  vpc_id                       = data.aws_ssm_parameter.vpc_id.value
  private_app_subnet_ids       = split(",", data.aws_ssm_parameter.private_app_subnet_ids.value)
  private_db_subnet_ids        = split(",", data.aws_ssm_parameter.private_db_subnet_ids.value)
  vpc_link_id                  = data.aws_ssm_parameter.vpc_link_id.value
  lb_private_arn               = data.aws_ssm_parameter.lb_private_arn.value
  lb_private_dns               = data.aws_ssm_parameter.lb_private_dns.value
  scale_rest_api_id            = module.api.scale_rest_api_id
  scale_rest_api_execution_arn = module.api.scale_rest_api_execution_arn
  parent_resource_id           = module.api.parent_resource_id
  ecs_security_group_id        = module.ecs.ecs_security_group_id
  ecs_task_execution_arn       = module.ecs.ecs_task_execution_arn
  ecs_cluster_id               = module.ecs.ecs_cluster_id
  agreements_db_endpoint       = data.aws_ssm_parameter.agreements_db_endpoint.value
  agreements_db_username       = data.aws_ssm_parameter.agreements_db_username.value
  agreements_db_password       = data.aws_ssm_parameter.agreements_db_password.value
  agreements_cpu               = var.agreements_cpu
  agreements_memory            = var.agreements_memory
}

module "api-deployment" {
  source            = "../../services/api-deployment"
  environment       = var.environment
  scale_rest_api_id = module.api.scale_rest_api_id
  api_rate_limit    = var.api_rate_limit
  api_burst_limit   = var.api_burst_limit

  // Simulate depends_on:
  agreements_api_gateway_integration = module.agreements.agreements_api_gateway_integration
}
