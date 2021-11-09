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

data "aws_ssm_parameter" "cidr_blocks_allowed_external_api_gateway" {
  name = "${lower(var.environment)}-cidr-blocks-allowed-external-api-gateway"
}

data "aws_ssm_parameter" "rollbar_access_token" {
  name = "${lower(var.environment)}-rollbar-access-token"
}

data "aws_ssm_parameter" "wordpress_root_url" {
  name = "${lower(var.environment)}-wordpress-root-url"
}

# Get the public IP values for NAT/GW to add to the API gateway allowed list
data "aws_ssm_parameter" "nat_eip_ids" {
  name = "${lower(var.environment)}-eip-ids-nat-gateway"
}

data "aws_eip" "nat_eips" {
  for_each = toset(split(",", data.aws_ssm_parameter.nat_eip_ids.value))

  id = each.key
}

locals {
  # Normalised CIDR blocks (accounting for 'none' i.e. "-" as value in SSM parameter)
  cidr_blocks_allowed_external_api_gateway = data.aws_ssm_parameter.cidr_blocks_allowed_external_api_gateway.value != "-" ? split(",", data.aws_ssm_parameter.cidr_blocks_allowed_external_api_gateway.value) : []
}

module "ecs" {
  source         = "../../ecs"
  vpc_id         = data.aws_ssm_parameter.vpc_id.value
  environment    = var.environment
  cidr_block_vpc = data.aws_ssm_parameter.cidr_block_vpc.value
}

module "api" {
  source      = "../../api"
  environment = var.environment

  # Allow traffic from VPC, NAT and environment specific CIDR ranges (e.g. CCS, CCS web infra etc)
  cidr_blocks_allowed_external_api_gateway = concat(tolist([data.aws_ssm_parameter.cidr_block_vpc.value]), values(data.aws_eip.nat_eips)[*].public_ip, local.cidr_blocks_allowed_external_api_gateway)
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
  agreements_db_username_arn   = data.aws_ssm_parameter.agreements_db_username.arn
  agreements_db_password_arn   = data.aws_ssm_parameter.agreements_db_password.arn
  agreements_cpu               = var.agreements_cpu
  agreements_memory            = var.agreements_memory
  ecr_image_id_agreements      = var.ecr_image_id_agreements
  ecs_log_retention_in_days    = var.ecs_log_retention_in_days
  rollbar_access_token         = data.aws_ssm_parameter.rollbar_access_token.arn
  wordpress_root_url           = data.aws_ssm_parameter.wordpress_root_url.arn
}

module "api-deployment" {
  source                       = "../../services/api-deployment"
  environment                  = var.environment
  scale_rest_api_id            = module.api.scale_rest_api_id
  api_rate_limit               = var.api_rate_limit
  api_burst_limit              = var.api_burst_limit
  api_gw_log_retention_in_days = var.api_gw_log_retention_in_days
  scale_rest_api_policy_json   = module.api.scale_rest_api_policy_json

  // Simulate depends_on:
  agreements_api_gateway_integration = module.agreements.agreements_api_gateway_integration
}

module "cloudwatch-alarms" {
  source                  = "../../cw-alarms"
  environment             = var.environment
  ecs_cluster_name        = module.ecs.ecs_cluster_name
  ecs_service_name        = module.agreements.ecs_service_name
  service_name            = "agreements"
  ecs_expected_task_count = length(split(",", data.aws_ssm_parameter.private_app_subnet_ids.value))
}
