data "aws_iam_role" "codepipeline_iam_role" {
  name = var.codepipeline_iam_role_name
}

data "aws_s3_bucket" "codepipeline_bucket" {
  bucket = var.codepipeline_bucket_name
}
