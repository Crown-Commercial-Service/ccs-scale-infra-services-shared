variable "agreements_service_codepipeline_project_name" {
  default = "agreements-service-pipeline"
}

variable "agreements_service_github_repository_name" {
  default = "ccs-scale-agreements-service"
}

variable "agreements_service_github_repository_url" {
  default = "https://github.com/Crown-Commercial-Service/ccs-scale-agreements-service.git"
}

variable "ccs_scale_infra_services_shared_github_repository_url" {
  default = "https://github.com/Crown-Commercial-Service/ccs-scale-infra-services-shared.git"
}

variable "development_environment_name" {
  default = "development"
}

variable "development_github_default_branch" {
  default = "develop"
}

variable "development_infra_shared_environment_name" {
  default = "tst"
}

variable "ecr_build_codebuild_project_name" {
  default = "agreements-service-ecr-build"
}

variable "ecs_deploy_codebuild_project_name" {
  default = "agreements-service-ecs-deploy"
}

variable "github_repository_name" {
  default = "ccs-scale-agreements-service"
}

variable "pre_production_environment_name" {
  default = "pre-production"
}

variable "pre_production_github_default_branch" {
  default = "staging"
}

variable "pre_production_infra_shared_environment_name" {
  default = "ppd"
}

variable "production_environment_name" {
  default = "production"
}

variable "production_github_default_branch" {
  default = "main"
}

variable "production_infra_shared_environment_name" {
  default = "prd"
}
