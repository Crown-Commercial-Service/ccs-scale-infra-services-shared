variable "cloudwatch_logs_stream_name" {
  default = "codebuild_logs"
}

variable "codebuild_iam_role_name" {
  type    = string
  default = "CCS_SCALE_CodeBuild"
}

variable "codebuild_project_name" {
  type = string
}

variable "codebuild_source" {
  type    = string
  default = "GITHUB"
}

variable "environment_compute_type" {
  type    = string
  default = "BUILD_GENERAL1_SMALL"
}

variable "environment_image" {
  type    = string
  default = "aws/codebuild/standard:3.0"
}

variable "environment_type" {
  type    = string
  default = "LINUX_CONTAINER"
}

variable "infra_shared_environment_name" {
  type        = string
  description = "Name of the environment subdir from which to run Terraform in the ccs-scale-infra-services-shared directory"
}

variable "github_repository_name" {
  type = string
}

variable "queued_timeout" {
  type    = number
  default = 10
}
