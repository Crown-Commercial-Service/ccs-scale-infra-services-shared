variable "logging_s3_bucket_name" {
  type    = string
  default = "agreements-service-pipeline-logging-s3-bucket"
}

variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "terraform_state_dynamodb_hash_key" {
  type    = string
  default = "LockID"
}

variable "terraform_state_dynamodb_table_name" {
  type    = string
  default = "agreements-service-pipeline-tfstate"
}

variable "terraform_state_s3_bucket_name" {
  type    = string
  default = "agreements-service-pipeline-terraform-state"
}
