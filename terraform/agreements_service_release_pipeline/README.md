# Agreements Service Release Pipeline

## Overview

This directory contains all of the configuration required for the Agreements Service Release Pipeline(s) - currently, we have
the following environments configured to leverage the Release Pipeline for the Agreements Service:

- Development (pointing to the "develop" branch for the [Agreements Service](https://github.com/Crown-Commercial-Service/ccs-scale-agreements-service), and
deploying to the [tst](../environments/tst) environment)
- Pre-Production (pointing to the "staging" branch for the [Agreements Service](https://github.com/Crown-Commercial-Service/ccs-scale-agreements-service), and
deploying to the [ppd](../environments/ppd) environment)
- Production (pointing to the "main" branch for the [Agreements Service](https://github.com/Crown-Commercial-Service/ccs-scale-agreements-service), and
deploying to the [prd](../environments/prd) environment)

### Configuration

The pipelines for each environment are configured by leveraging AWS CodePipeline. The configuration for each Pipeline can be found in the
[codepipeline](codepipeline) directory. 

As part of the CodePipeline configuration, we have also configured a couple of [codebuild](codebuild) jobs that suppliment the configured Pipeline
(along with the "Source" and "Approval" stages as necessary) in order to assist with the building of ECR Images and subsequent deployments to ECS.

### Notes:

Along with the [codepipeline](codepipeline) and [codebuild](codebuild) directories, the following sub-directories can be found here:
- [backend](backend) - this contains the backend configuration for managing the Terraform state/lock files that this project creates
- [common](common) - this contains common `.tf` files for resources that are used multiple times throughout this project
- [modules](modules) - this contains the declaration of each Terraform Module that is then subsequently leveraged by this project