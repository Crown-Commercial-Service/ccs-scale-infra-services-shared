variable "ecr_image_id_agreements" {
  type    = string
  default = "development-release-68"
}

variable "cognito_user_pool_arn" {
  type    = string
  default = "arn:aws:cognito-idp:eu-west-2:682179744484:userpool/eu-west-2_GFnrvKqTm"
}
