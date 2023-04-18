variable "codepipeline_bucket_name" {
  type    = string
  default = "scale-mgt-s3-codepipeline-artefacts"
}

variable "codepipeline_iam_role_name" {
  type    = string
  default = "CCS_SCALE_CodePipeline"
}

variable "codepipeline_project_name" {
  type = string
}

variable "default_branch" {
  type = string
}

variable "ecr_build_codebuild_project_name" {
  type = string
}

variable "ecs_deploy_codebuild_project_name" {
  type = string
}

variable "github_oauth_token" {
  type = string
}

variable "github_repository_name" {
  type = string
}