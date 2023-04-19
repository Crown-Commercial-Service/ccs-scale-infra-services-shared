resource "aws_codepipeline" "agreements_service_codepipeline" {
  name     = var.codepipeline_project_name
  role_arn = data.aws_iam_role.codepipeline_iam_role.arn

  artifact_store {
    location = data.aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      configuration = {
        Branch               = var.default_branch
        OAuthToken           = sensitive(var.github_oauth_token)
        Owner                = "Crown-Commercial-Service"
        PollForSourceChanges = true
        Repo                 = var.github_repository_name
      }

      category  = "Source"
      name      = "Source"
      namespace = "SourceVariables"
      owner     = "ThirdParty"
      provider  = "GitHub"
      version   = "1"

      output_artifacts = [
        "SourceArtifact"
      ]
    }
  }

  stage {
    name = "Build"

    action {
      configuration = {
        EnvironmentVariables = jsonencode([
          {
            name  = "BranchName"
            value = "#{SourceVariables.BranchName}"
            type  = "PLAINTEXT"
          }
        ])
        ProjectName = var.ecr_build_codebuild_project_name
      }

      category  = "Build"
      name      = "Build"
      namespace = "BuildVariables"
      owner     = "AWS"
      provider  = "CodeBuild"
      version   = "1"

      input_artifacts = [
        "SourceArtifact"
      ]

      output_artifacts = [
        "BuildArtifact"
      ]
    }
  }

  stage {
    name = "Approval"

    action {
      category = "Approval"
      name     = "Approval"
      owner    = "AWS"
      provider = "Manual"
      region   = "eu-west-2"
      version  = "1"
    }
  }

  stage {
    name = "Deploy"

    action {
      category = "Build"
      configuration = {
        EnvironmentVariables = jsonencode([
          {
            name  = "RELEASE_TAG"
            value = "#{BuildVariables.RELEASE_TAG}"
            type  = "PLAINTEXT"
          }
        ])
        "ProjectName" = var.ecs_deploy_codebuild_project_name
      }

      input_artifacts = [
        "BuildArtifact",
      ]

      name     = "Deploy"
      owner    = "AWS"
      provider = "CodeBuild"
      region   = "eu-west-2"
      version  = "1"
    }
  }
}