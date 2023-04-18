module "logging_s3_bucket_secure_transport_policy" {
  source        = "../../modules/secure_transport_policy"
  region        = var.region
  s3_bucket     = aws_s3_bucket.logging_s3_bucket.bucket
  s3_bucket_arn = aws_s3_bucket.logging_s3_bucket.arn
}

module "api_gateway_terraform_state_s3_bucket_secure_transport_policy" {
  source        = "../../modules/secure_transport_policy"
  region        = var.region
  s3_bucket     = aws_s3_bucket.terraform_state_s3_bucket.bucket
  s3_bucket_arn = aws_s3_bucket.terraform_state_s3_bucket.arn
}