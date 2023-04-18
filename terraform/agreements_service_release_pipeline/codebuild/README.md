# Codebuild

## Overview

This directory contains the configuration for the CodeBuild components for the Agreements Service [CodePipeline](../codepipeline).

There are two codebuild projects that are configured per environment:
- [ECR Build Codebuild](./ecr_build_codebuild.tf)
- [ECS Deploy CodeBuild](./ecs_deploy_codebuild.tf)

The individual CodeBuild jobs will live in the SCALE Management account (hence the [management](./management) subfolder in this directory) - 
the jobs are configured to then perform the relevant actions against the target environment.

### ECR Build CodeBuild
The [ECR Build Codebuild](./ecr_build_codebuild.tf) project is created by referencing the [agreements_service_ecr_build](../modules/agreements_service_ecr_build) 
module. This module contains the all of the configuration that is required to build an image from a given branch, and then push it to ECR with an
appropriate name for the release candidate. The module requires the following arguments:

- CodeBuild Project Name: The name of the CodeBuild Project for the ECR Build Project
- Environment: The name of the Agreements Service Environment that you are building the ECR Image for
- Github Repository Name: The URL of the Agreements Service repository, from which the ECR Image is built
- Source Version: The name of the branch in the Agreements Service repository from which the ECR Image will be built

This project will do the following, as per the [buildspec.yml](../modules/agreements_service_ecr_build/buildspec.yml) file:
- Install the pre-requisites needed for the project (e.g. Java, Docker, Maven etc)
- Log into the relevant AWS ECR account
- Package and build the image, using the relevant Github Repository and Git Branch
- Once the image is built, it will then be pushed into the relevant AWS ECR repository

Within the [CodePipeline](../codepipeline) for the Agreements Service, the RELEASE_TAG that is created for this job will then
be passed to the [ECS Deploy CodeBuild](./ecs_deploy_codebuild.tf) step as appropriate.

_Note: The name of the image (RELEASE_TAG) that is pushed to ECR will follow the naming convention of ${ENVIRONMENT}-release-${CODEBUILD_BUILD_NUMBER} - so
for example, if you were building an image for the development environment, and this was the 5th invocation of the CodeBuild job,
the project would create an image named development-release-5._

### ECS Deploy CodeBuild
The [ECS Deploy CodeBuild](./ecs_deploy_codebuild.tf) is created by referencing in [agreements_service_ecs_deploy](../modules/agreements_service_ecs_deploy) module.
This module contains all of the configuration that is required to perform a deployment from a given RELEASE_TAG/release candidate. This job performs a deployment
to ECS by doing the following:

- Taking the RELEASE_TAG that is created by the [ECR Build Codebuild](./ecr_build_codebuild.tf) step
- Installing all necessary pre-requisites
- Changing into the relevant [environments](../../environments) subdirectory (e.g. environments/tst/)
- Running a Terraform apply that targets the ECS Service and ECS Task Definition for the Agreements Service
- This updates the task definition to point to the newly created ECR Image (as per the [ECR Build Codebuild](./ecr_build_codebuild.tf) job)
and then provides the updated task definition to the ECS Service, forcing a deployment

_Note: Once this job completes, in the background the Target Group for the Agreements Service for the account you are deploying to will be updated
to point to the newly created ECS task, containing the up to date configuration._