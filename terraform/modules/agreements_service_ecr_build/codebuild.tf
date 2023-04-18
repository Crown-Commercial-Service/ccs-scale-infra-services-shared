resource "aws_codebuild_project" "agreements_service_ecr_build_codebuild_project" {
  name           = var.codebuild_project_name
  queued_timeout = var.queued_timeout
  service_role   = data.aws_iam_role.ccs_scale_codebuild.arn
  source_version = var.source_version

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    modes = [
      "LOCAL_DOCKER_LAYER_CACHE",
      "LOCAL_SOURCE_CACHE"
    ]
    type = "LOCAL"
  }

  environment {
    compute_type    = var.environment_compute_type
    image           = var.environment_image
    privileged_mode = true
    type            = var.environment_type

    environment_variable {
      name  = "ECR_REPOSITORY"
      type  = "PLAINTEXT"
      value = var.ecr_repository_name
    }

    environment_variable {
      name  = "ENVIRONMENT"
      type  = "PLAINTEXT"
      value = var.environment
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "${var.codebuild_project_name}-logs"
      stream_name = var.cloudwatch_logs_stream_name
    }
  }

  source {
    buildspec       = data.local_file.buildspec.content
    git_clone_depth = 1
    location        = var.github_repository_url
    type            = var.codebuild_source

    auth {
      type = "OAUTH"
    }
  }
}