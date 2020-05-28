output "agreements_api_gateway_integration" {
  value = aws_api_gateway_integration.agreements_proxy.http_method
}
