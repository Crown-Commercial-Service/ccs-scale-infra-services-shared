#########################################################
# Infrastructure: API
#
# Deploy API Gateway account level resources.
# API Deployments are done later, after services.
#########################################################
module "globals" {
  source = "../globals"
}

# Data source for NLB
data "aws_lb" "scale_lb" {
  name = "SCALE-EU2-TST-NLB-INTERNAL"
}

# API Gateway account level settings
resource "aws_api_gateway_account" "this" {
  cloudwatch_role_arn = aws_iam_role.api_gw_cloudwatch_logs_role.arn
}

resource "aws_iam_role" "api_gw_cloudwatch_logs_role" {
  name = "SCALE_Shared_ApiGateway_PushToCWLog"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = {
    Project     = module.globals.project_name
    Environment = upper(var.environment)
    Cost_Code   = module.globals.project_cost_code
    AppType     = "APIGATEWAY"
  }
}

resource "aws_iam_role_policy" "cloudwatch" {
  name   = "default"
  role   = aws_iam_role.api_gw_cloudwatch_logs_role.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

# API gateway, top-level..
data "aws_iam_policy_document" "scale" {
  source_json = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "execute-api:Invoke",
            "Resource": "*",
            "Condition" : {
                "IpAddress": {
                    "aws:SourceIp": ${jsonencode(var.cidr_blocks_allowed_external_api_gateway)}
                }
            }
        }
    ]
}
EOF
}

resource "aws_api_gateway_rest_api" "scale" {
  name        = "SCALE:EU2:${upper(var.environment)}:API:Shared"
  description = "SCALE API Gateway"

  endpoint_configuration {
    types = ["EDGE"]
  }

  policy = data.aws_iam_policy_document.scale.json

  tags = {
    Project     = module.globals.project_name
    Environment = upper(var.environment)
    Cost_Code   = module.globals.project_cost_code
    AppType     = "APIGATEWAY"
  }
}

resource "aws_api_gateway_method" "scale_get_method" {
  rest_api_id      = aws_api_gateway_rest_api.scale.id
  resource_id      = aws_api_gateway_resource.scale.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true

}

resource "aws_api_gateway_vpc_link" "scale_vpc_link" {
  name        = "SCALE:EU2:ENV:VPC:Link"
  target_arns = [data.aws_lb.scale_lb.arn]
}

resource "aws_api_gateway_integration" "scale_get_method_integration" {
  rest_api_id     = aws_api_gateway_rest_api.scale.id
  resource_id     = aws_api_gateway_resource.scale.id
  http_method     = aws_api_gateway_method.scale_get_method.http_method
  type            = "HTTP"
  connection_type = "VPC_LINK"
  connection_id   = aws_api_gateway_vpc_link.scale_vpc_link.id

}


# Default Access Denied gateway response exposes info about the API so replace it.
resource "aws_api_gateway_gateway_response" "access_denied" {
  rest_api_id   = aws_api_gateway_rest_api.scale.id
  status_code   = "403"
  response_type = "ACCESS_DENIED"

  response_templates = {
    "application/json" = jsonencode({ "message" = "Access denied" })
  }
}

# Base path resources (/scale/)
resource "aws_api_gateway_resource" "scale" {
  rest_api_id = aws_api_gateway_rest_api.scale.id
  parent_id   = aws_api_gateway_rest_api.scale.root_resource_id
  path_part   = "scale"
}
