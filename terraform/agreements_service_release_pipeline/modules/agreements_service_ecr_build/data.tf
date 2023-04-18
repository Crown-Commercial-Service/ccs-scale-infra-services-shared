data "aws_iam_role" "ccs_scale_codebuild" {
  name = var.codebuild_iam_role_name
}

data "local_file" "buildspec" {
  filename = "${path.module}/buildspec.yml"
}
