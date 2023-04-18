resource "aws_dynamodb_table" "terraform_state_dynamodb_table" {
  hash_key       = var.terraform_state_dynamodb_hash_key
  name           = "${var.terraform_state_dynamodb_table_name}-${var.environment}"
  read_capacity  = 5
  write_capacity = 5

  attribute {
    name = "LockID"
    type = "S"
  }
}
