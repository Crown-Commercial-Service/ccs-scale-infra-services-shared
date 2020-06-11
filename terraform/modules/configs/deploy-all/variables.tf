variable "aws_account_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "ecr_image_id_agreements" {
  type = string
  default = "7256128-snapshot"
}
