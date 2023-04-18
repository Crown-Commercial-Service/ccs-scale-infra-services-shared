resource "aws_codebuild_project" "agreements_service_ecs_deploy" {
  name           = var.codebuild_project_name
  queued_timeout = var.queued_timeout
  service_role   = data.aws_iam_role.ccs_scale_codebuild.arn

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
    privileged_mode = false
    type            = var.environment_type

    environment_variable {
      name  = "INFRA_SHARED_ENVIRONMENT"
      type  = "PLAINTEXT"
      value = var.infra_shared_environment_name
    }

    environment_variable {
      name  = "TF_ACTION"
      type  = "PLAINTEXT"
      value = "apply"
    }

    environment_variable {
      name  = "TF_LOG"
      type  = "PLAINTEXT"
      value = "INFO"
    }

    environment_variable {
      name  = "TF_VAR_ec2_key_pair"
      type  = "PLAINTEXT"
      value = "ccs-spree-key"
    }

    environment_variable {
      name  = "TF_VERSION"
      type  = "PLAINTEXT"
      value = "0.13.3"
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
    location        = var.github_repository_name
    type            = var.codebuild_source

    auth {
      type = "OAUTH"
    }
  }
}
