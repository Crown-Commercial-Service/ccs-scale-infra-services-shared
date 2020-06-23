variable "vpc_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "cidr_blocks_app" {
  type = list(string)
}

variable "cidr_block_vpc" {
  type = string
}
