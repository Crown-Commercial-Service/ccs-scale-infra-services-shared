#########################################################
# Service: API Deployments
#
# Creates Usage Plan/API Keys and deployment.
#########################################################

#########################################################
# Deployment
#########################################################
resource "aws_api_gateway_deployment" "shared" {
  description = "Deployed at ${timestamp()}"
  rest_api_id = var.scale_rest_api_id

  depends_on = [
    var.agreements_api_gateway_integration
  ]

  triggers = {
    api_errors = filesha1("${path.module}/../../api/api-errors.tf")
    error_response = filesha1("${path.module}/../../api/error-response.json.tpl")
    rest_api_main = filesha1("${path.module}/../../api/main.tf")
    api_integration = filesha1("${path.module}/../agreements/api.tf")
    redeployment = sha1(var.scale_rest_api_policy_json)
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "shared" {
  description = "Deployed at ${timestamp()}"
  depends_on = [
    aws_cloudwatch_log_group.api_gw_execution
  ]

  stage_name    = lower(var.environment)
  rest_api_id   = var.scale_rest_api_id
  deployment_id = aws_api_gateway_deployment.shared.id
}

resource "aws_api_gateway_method_settings" "scale" {
  rest_api_id = var.scale_rest_api_id
  stage_name  = aws_api_gateway_stage.shared.stage_name
  method_path = "*/*"
  settings {
    logging_level      = "INFO"
    data_trace_enabled = true
    metrics_enabled    = true
  }
}

resource "aws_cloudwatch_log_group" "api_gw_execution" {
  name              = "API-Gateway-Execution-Logs_${var.scale_rest_api_id}/${lower(var.environment)}-shared"
  retention_in_days = var.api_gw_log_retention_in_days
}

resource "aws_ssm_parameter" "api_invoke_url" {
  name      = "${lower(var.environment)}-agreements-service-root-url"
  type      = "String"
  value     = aws_api_gateway_stage.shared.invoke_url
  overwrite = true
}

#########################################################
# Usage Plans
#########################################################
resource "aws_api_gateway_usage_plan" "default" {
  name        = "default-usage-plan-shared"
  description = "Default Usage Plan"

  api_stages {
    api_id = var.scale_rest_api_id
    stage  = aws_api_gateway_stage.shared.stage_name
  }

  throttle_settings {
    rate_limit  = var.api_rate_limit
    burst_limit = var.api_burst_limit
  }
}

#########################################################
# API Keys
#########################################################
resource "aws_api_gateway_api_key" "fat_buyer_ui" {
  name = "FaT Buyer UI API Key (Shared)"
}

resource "aws_api_gateway_api_key" "fat_testers" {
  name = "FaT Testers API Key (Shared)"
}

resource "aws_api_gateway_api_key" "fat_developers" {
  name = "FaT Developers API Key (Shared)"
}

resource "aws_api_gateway_api_key" "bat_developers" {
  name = "BaT Developers API Key (Shared)"
}

resource "aws_api_gateway_api_key" "apig" {
  name = "Enterprise API Gateway API Key (Shared)"
}

resource "aws_api_gateway_usage_plan_key" "fat_buyer_ui" {
  key_id        = aws_api_gateway_api_key.fat_buyer_ui.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.default.id
}

resource "aws_api_gateway_usage_plan_key" "fat_testers" {
  key_id        = aws_api_gateway_api_key.fat_testers.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.default.id
}

resource "aws_api_gateway_usage_plan_key" "fat_developers" {
  key_id        = aws_api_gateway_api_key.fat_developers.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.default.id
}

resource "aws_api_gateway_usage_plan_key" "bat_developers" {
  key_id        = aws_api_gateway_api_key.bat_developers.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.default.id
}

resource "aws_api_gateway_usage_plan_key" "apig" {
  key_id        = aws_api_gateway_api_key.apig.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.default.id
}

resource "aws_ssm_parameter" "fat_buyer_ui_api_key" {
  name        = "${lower(var.environment)}-fat-buyer-ui-shared-api-key"
  description = "API Key for FaT Buyer UI component to use to access the Shared API (Agreements Service)"
  type        = "String"
  value       = aws_api_gateway_api_key.fat_buyer_ui.value
  overwrite   = true
}
