# CodePipeline

## Overview

This directory contains the configuration for the CodePipeline components for the Agreements Service CodePipeline.
The configuration for each environment's individual CodePipeline is defined in the [agreements_service_codepipeline](agreements_service_codepipeline.tf) file.
This file leverages the [agreements_service_codepipeline module](../modules/agreements_service_codepipeline), passing in the required variables as appropriate.

Each individual CodePipeline job will live in the SCALE Management account (hence the [management](./management) subfolder in this directory) - the jobs are configured
to then perform the relevant actions against the target environment.

### Arguments

The [agreements_service_codepipeline module](../modules/agreements_service_codepipeline) requires the following arguments to be provided:

- CodePipeline Project Name: The name of the CodePipeline project to be created/managed by Terraform
- Default Branch: The branch from which any changes are sourced by the CodePipeline (and images for the Agreements Service are subsequently built from)
- ECR Build CodeBuild Project Name: The name of the [ecr_build_codebuild](../codebuild) project that builds and deploys the ECR Image for the Agreements Service
- ECS Deploy CodeBuild Project Name: The name of the [ecs_deploy_codebuild](../codebuild) project that deploys the above ECR Image to ECS
- Github OAuth Token: The Github OAuth Token that is used in order to authenticate with Github (to poll for any changes on the specified branch for the Agreements Service)
- Github Repository Name: The name of the Github repository for the Agreements Service

_Note: These are defined in the [agreements_service_codepipeline](agreements_service_codepipeline.tf) file for each environment_

### Behaviour

The CodePipeline that is provisioned for each environment has the following stages/behaviour:
- Source: This is the first step in the Pipeline, and will monitor for any changes to the specified branch on the target repository. If a change is pushed to the
branch, this will trigger the CodePipeline
- Build: This step will build and deploy a custom ECR Image for the project by leveraging the [ecr_build_codebuild](../codebuild) job
- Approval: This is a manual approval step, where a user must either "approve" or "reject" the proposal to perform a deployment
- Deploy: Assuming the user opts to "approve" the above step, this will trigger an ECS Deployment by leveraging the [ecs_deploy_codebuild](../codebuild) project (using the
ECR Image created in the Build step)

_Note: Once this job completes, in the background the Target Group for the Agreements Service for the account you are deploying to will be updated
to point to the newly created ECS task, containing the up to date configuration._