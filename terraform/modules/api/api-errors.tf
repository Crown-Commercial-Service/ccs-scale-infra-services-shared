#############################################################
# Infrastructure: API Errors
#
# This overwrites the following error responses in the 
# 'Gateway Responses' section of the AI Gateway.
#
# Only those that are explicitly referenced in the Open API
# definition are overwritten (to match the format specified).
#############################################################

###################
# 4XX - Default 4XX
###################

data "template_file" "error_default_4xx" {
  template = "${file("${path.module}/error-response.json.tpl")}"
  vars = {
    error_status      = "4XX"
    error_title       = "Bad request"
    error_detail      = "Invalid request"
    error_description = "Invalid request"
  }
}

resource "aws_api_gateway_gateway_response" "error_default_4xx" {
  rest_api_id   = aws_api_gateway_rest_api.scale.id
  response_type = "DEFAULT_4XX"

  response_templates = {
    "application/json" = data.template_file.error_default_4xx.rendered
  }
}

###################
# 5XX - Default 5XX
###################

resource "aws_api_gateway_gateway_response" "error_default_5xx" {
  rest_api_id   = aws_api_gateway_rest_api.scale.id
  response_type = "DEFAULT_5XX"

  response_templates = {
    "application/json" = "{\"description\":\"An unknown error has occurred\"}"
  }
}

########################
# 400 - Bad request body
########################

data "template_file" "error_bad_request_body" {
  template = "${file("${path.module}/error-response.json.tpl")}"
  vars = {
    error_status      = "400"
    error_title       = "Bad request"
    error_detail      = "Bad request body"
    error_description = "Invalid request"
  }
}

resource "aws_api_gateway_gateway_response" "error_bad_request_body" {
  rest_api_id   = aws_api_gateway_rest_api.scale.id
  response_type = "BAD_REQUEST_BODY"

  response_templates = {
    "application/json" = data.template_file.error_bad_request_body.rendered
  }
}

##############################
# 400 - Bad request parameters
##############################

data "template_file" "error_bad_request_parameters" {
  template = "${file("${path.module}/error-response.json.tpl")}"
  vars = {
    error_status      = "400"
    error_title       = "Bad request"
    error_detail      = "Bad request parameters"
    error_description = "Invalid request"
  }
}

resource "aws_api_gateway_gateway_response" "error_bad_request_parameters" {
  rest_api_id   = aws_api_gateway_rest_api.scale.id
  response_type = "BAD_REQUEST_PARAMETERS"

  response_templates = {
    "application/json" = data.template_file.error_bad_request_parameters.rendered
  }
}

###########################
# 403 - Missing auth token
###########################

data "template_file" "error_missing_authentication_token" {
  template = "${file("${path.module}/error-response.json.tpl")}"
  vars = {
    error_status      = "403"
    error_title       = "Forbidden"
    error_detail      = "Missing authentication token"
    error_description = "You are not authorized to access this resource"
  }
}

resource "aws_api_gateway_gateway_response" "error_missing_authentication_token" {
  rest_api_id   = aws_api_gateway_rest_api.scale.id
  status_code   = "403"
  response_type = "MISSING_AUTHENTICATION_TOKEN"

  response_templates = {
    "application/json" = data.template_file.error_missing_authentication_token.rendered
  }
}

#########################
# 403 - Invalid signature
#########################

data "template_file" "error_invalid_signature" {
  template = "${file("${path.module}/error-response.json.tpl")}"
  vars = {
    error_status      = "403"
    error_title       = "Forbidden"
    error_detail      = "Invalid signature"
    error_description = "You are not authorized to access this resource"
  }
}

resource "aws_api_gateway_gateway_response" "error_invalid_signature" {
  rest_api_id   = aws_api_gateway_rest_api.scale.id
  status_code   = "403"
  response_type = "INVALID_SIGNATURE"

  response_templates = {
    "application/json" = data.template_file.error_invalid_signature.rendered
  }
}

#######################
# 403 - Invalid API key
#######################

data "template_file" "error_invalid_api_key" {
  template = "${file("${path.module}/error-response.json.tpl")}"
  vars = {
    error_status      = "403"
    error_title       = "Forbidden"
    error_detail      = "Invalid API key"
    error_description = "You are not authorized to access this resource"
  }
}

resource "aws_api_gateway_gateway_response" "error_invalid_api_key" {
  rest_api_id   = aws_api_gateway_rest_api.scale.id
  status_code   = "403"
  response_type = "INVALID_API_KEY"

  response_templates = {
    "application/json" = data.template_file.error_invalid_api_key.rendered
  }
}

#####################
# 403 - Expired token
#####################

data "template_file" "error_expired_token" {
  template = "${file("${path.module}/error-response.json.tpl")}"
  vars = {
    error_status      = "403"
    error_title       = "Forbidden"
    error_detail      = "Expired token"
    error_description = "You are not authorized to access this resource"
  }
}

resource "aws_api_gateway_gateway_response" "error_expired_token" {
  rest_api_id   = aws_api_gateway_rest_api.scale.id
  status_code   = "403"
  response_type = "EXPIRED_TOKEN"

  response_templates = {
    "application/json" = data.template_file.error_expired_token.rendered
  }
}

####################
# 403 - WAF filtered
####################

data "template_file" "error_waf_filtered" {
  template = "${file("${path.module}/error-response.json.tpl")}"
  vars = {
    error_status      = "403"
    error_title       = "Forbidden"
    error_detail      = "WAF filtered"
    error_description = "You are not authorized to access this resource"
  }
}

resource "aws_api_gateway_gateway_response" "error_waf_filtered" {
  rest_api_id   = aws_api_gateway_rest_api.scale.id
  status_code   = "403"
  response_type = "WAF_FILTERED"

  response_templates = {
    "application/json" = data.template_file.error_waf_filtered.rendered
  }
}

##########################
# 404 - Resource not found
##########################

data "template_file" "error_resource_not_found" {
  template = "${file("${path.module}/error-response.json.tpl")}"
  vars = {
    error_status      = "404"
    error_title       = "Resource not found"
    error_detail      = "Resource not found"
    error_description = "The resource you were looking for could not be found"
  }
}

resource "aws_api_gateway_gateway_response" "error_resource_not_found" {
  rest_api_id   = aws_api_gateway_rest_api.scale.id
  status_code   = "404"
  response_type = "RESOURCE_NOT_FOUND"

  response_templates = {
    "application/json" = data.template_file.error_resource_not_found.rendered
  }
}

######################
# 429 - Quota Exceeded
######################

data "template_file" "error_quota_exceeded" {
  template = "${file("${path.module}/error-response.json.tpl")}"
  vars = {
    error_status      = "429"
    error_title       = "Too many requests"
    error_detail      = "Quota exceeded"
    error_description = "The resource has recieved to many requests"
  }
}

resource "aws_api_gateway_gateway_response" "error_quota_exceeded" {
  rest_api_id   = aws_api_gateway_rest_api.scale.id
  status_code   = "429"
  response_type = "THROTTLED"

  response_templates = {
    "application/json" = data.template_file.error_quota_exceeded.rendered
  }
}


###########################
# 504 - Integration failure
###########################

data "template_file" "error_integration_faiure" {
  template = "${file("${path.module}/error-response.json.tpl")}"
  vars = {
    error_status      = "504"
    error_title       = "Gateway timeout"
    error_detail      = "Integration failure"
    error_description = "Gateway timeout"
  }
}

resource "aws_api_gateway_gateway_response" "error_integration_faiure" {
  rest_api_id   = aws_api_gateway_rest_api.scale.id
  status_code   = "504"
  response_type = "INTEGRATION_FAILURE"

  response_templates = {
    "application/json" = data.template_file.error_integration_faiure.rendered
  }
}

###########################
# 504 - Integration timeout
###########################

data "template_file" "error_integration_timeout" {
  template = "${file("${path.module}/error-response.json.tpl")}"
  vars = {
    error_status      = "504"
    error_title       = "Gateway timeout"
    error_detail      = "Integration timeout"
    error_description = "Gateway timeout"
  }
}

resource "aws_api_gateway_gateway_response" "error_integration_timeout" {
  rest_api_id   = aws_api_gateway_rest_api.scale.id
  status_code   = "504"
  response_type = "INTEGRATION_TIMEOUT"

  response_templates = {
    "application/json" = data.template_file.error_integration_timeout.rendered
  }
}
