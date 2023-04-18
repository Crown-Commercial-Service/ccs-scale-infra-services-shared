terraform {
  backend "s3" {
    bucket         = "agreements-service-pipeline-terraform-state-management"
    key            = "codebuild/management/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "agreements-service-pipeline-tfstate-management"
  }
}