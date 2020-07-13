output "agreements_api_gateway_integration" {
  value = aws_api_gateway_integration.agreements_proxy.http_method
}

output "ecs_service_name" {
  value = aws_ecs_service.agreements.name
}
