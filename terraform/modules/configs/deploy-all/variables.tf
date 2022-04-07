variable "aws_account_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "ecr_image_id_agreements" {
  type    = string
  default = "eaf9f37-candidate"
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

variable "api_gw_log_retention_in_days" {
  type    = number
  default = 7
}

variable "ecs_log_retention_in_days" {
  type    = number
  default = 7
}
