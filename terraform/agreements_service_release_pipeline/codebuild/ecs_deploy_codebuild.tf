module "development_agreements_service_ecs_deploy" {
  source                        = "../../modules/agreements_service_ecs_deploy"
  codebuild_project_name        = "${var.development_environment_name}-${var.ecs_deploy_codebuild_project_name}"
  infra_shared_environment_name = var.development_infra_shared_environment_name
  github_repository_name        = var.ccs_scale_infra_services_shared_github_repository_url
}

module "pre_production_agreements_service_ecs_deploy" {
  source                        = "../../modules/agreements_service_ecs_deploy"
  codebuild_project_name        = "${var.pre_production_environment_name}-${var.ecs_deploy_codebuild_project_name}"
  infra_shared_environment_name = var.pre_production_infra_shared_environment_name
  github_repository_name        = var.ccs_scale_infra_services_shared_github_repository_url
}

module "production_agreements_service_ecs_deploy" {
  source                        = "../../modules/agreements_service_ecs_deploy"
  codebuild_project_name        = "${var.production_environment_name}-${var.ecs_deploy_codebuild_project_name}"
  infra_shared_environment_name = var.production_infra_shared_environment_name
  github_repository_name        = var.ccs_scale_infra_services_shared_github_repository_url
}
