module "development_agreements_service_ecr_build_codebuild_project" {
  source                 = "../../modules/agreements_service_ecr_build"
  codebuild_project_name = "${var.development_environment_name}-${var.ecr_build_codebuild_project_name}"
  environment            = var.development_environment_name
  github_repository_url  = var.agreements_service_github_repository_url
  source_version         = var.development_github_default_branch
}

module "pre_production_agreements_service_ecr_build_codebuild_project" {
  source                 = "../../modules/agreements_service_ecr_build"
  codebuild_project_name = "${var.pre_production_environment_name}-${var.ecr_build_codebuild_project_name}"
  environment            = var.pre_production_environment_name
  github_repository_url  = var.agreements_service_github_repository_url
  source_version         = var.pre_production_github_default_branch
}

module "production_agreements_service_ecr_build_codebuild_project" {
  source                 = "../../modules/agreements_service_ecr_build"
  codebuild_project_name = "${var.production_environment_name}-${var.ecr_build_codebuild_project_name}"
  environment            = var.production_environment_name
  github_repository_url  = var.agreements_service_github_repository_url
  source_version         = var.production_github_default_branch
}
