module "development_agreements_service_codepipeline" {
  source                            = "../../modules/agreements_service_codepipeline"
  codepipeline_project_name         = "${var.development_environment_name}-${var.agreements_service_codepipeline_project_name}"
  default_branch                    = var.development_github_default_branch
  ecr_build_codebuild_project_name  = "${var.development_environment_name}-${var.ecr_build_codebuild_project_name}"
  ecs_deploy_codebuild_project_name = "${var.development_environment_name}-${var.ecs_deploy_codebuild_project_name}"
  github_oauth_token                = var.github_oauth_token
  github_repository_name            = var.agreements_service_github_repository_name
}

module "pre_production_agreements_service_codepipeline" {
  source                            = "../../modules/agreements_service_codepipeline"
  codepipeline_project_name         = "${var.pre_production_environment_name}-${var.agreements_service_codepipeline_project_name}"
  default_branch                    = var.pre_production_github_default_branch
  ecr_build_codebuild_project_name  = "${var.pre_production_environment_name}-${var.ecr_build_codebuild_project_name}"
  ecs_deploy_codebuild_project_name = "${var.pre_production_environment_name}-${var.ecs_deploy_codebuild_project_name}"
  github_oauth_token                = var.github_oauth_token
  github_repository_name            = var.agreements_service_github_repository_name
}

module "production_agreements_service_codepipeline" {
  source                            = "../../modules/agreements_service_codepipeline"
  codepipeline_project_name         = "${var.production_environment_name}-${var.agreements_service_codepipeline_project_name}"
  default_branch                    = var.production_github_default_branch
  ecr_build_codebuild_project_name  = "${var.production_environment_name}-${var.ecr_build_codebuild_project_name}"
  ecs_deploy_codebuild_project_name = "${var.production_environment_name}-${var.ecs_deploy_codebuild_project_name}"
  github_oauth_token                = var.github_oauth_token
  github_repository_name            = var.agreements_service_github_repository_name
}
