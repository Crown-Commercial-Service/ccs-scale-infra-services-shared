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
  retention_in_days = 7
}

resource "aws_ssm_parameter" "api_invoke_url" {
  name  = "${lower(var.environment)}-agreements-service-root-url"
  type  = "String"
  value = aws_api_gateway_stage.shared.invoke_url
}

#########################################################
# Usage Plans
#########################################################
resource "aws_api_gateway_usage_plan" "default" {
  name        = "default-usage-plan"
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
resource "aws_api_gateway_api_key" "buyer_ui" {
  name = "Buyer UI API Key"
}

resource "aws_api_gateway_api_key" "testers" {
  name = "Testers API Key"
}

resource "aws_api_gateway_api_key" "developers" {
  name = "Developers API Key"
}

resource "aws_api_gateway_usage_plan_key" "buyer_ui" {
  key_id        = aws_api_gateway_api_key.buyer_ui.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.default.id
}

resource "aws_api_gateway_usage_plan_key" "testers" {
  key_id        = aws_api_gateway_api_key.testers.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.default.id
}

resource "aws_api_gateway_usage_plan_key" "developers" {
  key_id        = aws_api_gateway_api_key.developers.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.default.id
}
