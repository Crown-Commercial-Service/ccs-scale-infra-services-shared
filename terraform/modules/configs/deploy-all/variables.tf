variable "aws_account_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "agreements_cpu" {
  type    = number
  default = 512
}

variable "agreements_memory" {
  type    = number
  default = 1024
}
