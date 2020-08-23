variable "aws_account_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "ecr_image_id_agreements" {
  type    = string
  default = "5c8ea7b-candidate"
}

variable "agreements_cpu" {
  type    = number
  default = 512
}

variable "agreements_memory" {
  type    = number
  default = 1024
}

variable "api_rate_limit" {
  type    = number
  default = 100
}

variable "api_burst_limit" {
  type    = number
  default = 50
}
