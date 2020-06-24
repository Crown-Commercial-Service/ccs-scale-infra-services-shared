#########################################################
# API Deployment: FaT
#
# Deploy updated API Gateway.
#########################################################
resource "aws_api_gateway_deployment" "shared" {
  description = "Deployed at ${timestamp()}"
  rest_api_id = var.scale_rest_api_id

  depends_on = [
    var.agreements_api_gateway_integration
  ]

  # This will force a deployment of the updated API
  variables = {
    deployed_at = "${timestamp()}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "shared" {
  description = "Deployed at ${timestamp()}"

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

resource "aws_ssm_parameter" "api_invoke_url" {
  name  = "${lower(var.environment)}-agreements-service-root-url"
  type  = "String"
  value = aws_api_gateway_stage.shared.invoke_url
}
