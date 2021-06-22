#########################################################
# Service: Agreements API
#
# Deploy API Gateway resources for service.
#########################################################
resource "aws_api_gateway_resource" "agreements" {
  rest_api_id = var.scale_rest_api_id
  parent_id   = var.parent_resource_id
  path_part   = "agreements-service"
}

resource "aws_api_gateway_resource" "agreements_proxy" {
  rest_api_id = var.scale_rest_api_id
  parent_id   = aws_api_gateway_resource.agreements.id

  # Proxy all requests to /agreements-service/* through to backend
  path_part = "{proxy+}"
}

module "agreements_cors" {
  source          = "squidfunk/api-gateway-enable-cors/aws"
  version         = "0.3.1"
  api_id          = var.scale_rest_api_id
  api_resource_id = aws_api_gateway_resource.agreements_proxy.id
  allow_headers   = module.globals.allowed_cors_headers
}

resource "aws_api_gateway_method" "agreements_proxy" {
  rest_api_id      = var.scale_rest_api_id
  resource_id      = aws_api_gateway_resource.agreements_proxy.id
  http_method      = "ANY"
  authorization    = "NONE"
  api_key_required = true

  request_parameters = {
    "method.request.path.proxy" = false
  }
}

resource "aws_api_gateway_integration" "agreements_proxy" {
  rest_api_id             = var.scale_rest_api_id
  resource_id             = aws_api_gateway_resource.agreements_proxy.id
  http_method             = aws_api_gateway_method.agreements_proxy.http_method
  type                    = "HTTP_PROXY"
  uri                     = "http://${var.lb_private_dns}:9010/{proxy}"
  connection_type         = "VPC_LINK"
  connection_id           = var.vpc_link_id
  integration_http_method = "ANY"
  cache_key_parameters    = ["method.request.path.proxy"]
  cache_namespace         = "agreements"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

module "api_errors" {
  source        = "../../api-errors"
  rest_api_id   = var.scale_rest_api_id
}

#resource "aws_api_gateway_method_response" "response_200" {
#  rest_api_id = var.scale_rest_api_id
#  resource_id = aws_api_gateway_resource.agreements_proxy.id
#  http_method = aws_api_gateway_method.agreements_proxy.http_method
#  status_code = "403"
#}


#resource "aws_api_gateway_integration_response" "MyDemoIntegrationResponse" {
#  rest_api_id = var.scale_rest_api_id
#  resource_id = aws_api_gateway_resource.agreements_proxy.id
#  status_code = aws_api_gateway_method_response.response_200.status_code
#  http_method = aws_api_gateway_method.agreements_proxy.http_method
  #response_type = "FORBIDDEN"

#  response_templates = {
#    "application/json" = "{\"errors\":[{\"status\":\"string\",\"title\":$context.error.messageString,\"detail\":$context.error.messageString}],\"description\":\"You are not authorized to access this resource.\"}"
#  }
#}

#####
# 403
#####

#resource "aws_api_gateway_gateway_response" "error_missing_authentication_token" {
#  rest_api_id   = var.scale_rest_api_id
#  status_code   = "403"
#  response_type = "MISSING_AUTHENTICATION_TOKEN"

#  response_templates = {
#    "application/json" = "{\"errors\":[{\"status\":\"string\",\"title\":$context.error.messageString,\"detail\":$context.error.messageString}],\"description\":\"You are not authorized to access this resource.\"}"
#  }
#}


#####
# 4XX
#####

#resource "aws_api_gateway_gateway_response" "error_default_4xx" {
#  rest_api_id   = var.scale_rest_api_id
#  response_type = "DEFAULT_4XX"
#  status_code   = "4XX"

#  response_templates = {
#    "application/json" = "{\"errors\":[{\"status\":\"4XX\",\"title\":$context.error.messageString,\"detail\":$context.error.messageString}],\"description\":\"You are not authorized to access this resource.\"}"
#  }
#}

#####
# 5XX
#####

#resource "aws_api_gateway_gateway_response" "error_default_5xx" {
#  rest_api_id   = var.scale_rest_api_id
#  response_type = "DEFAULT_5XX"
#  status_code   = "5XX"

#  response_templates = {
#    "application/json" = "{\"errors\":[{\"status\":\"5XX\",\"title\":$context.error.messageString,\"detail\":$context.error.messageString}],\"description\":\"You are not authorized to access this resource.\"}"
#  }
#}