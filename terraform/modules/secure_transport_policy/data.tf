data "aws_iam_policy_document" "secure_transport_policy" {
  statement {
    effect = "Deny"

    principals {
      identifiers = ["*"]
      type        = "*"
    }

    actions = [
      "s3:*",
    ]

    condition {
      test = "Bool"

      values = [
        "false",
      ]

      variable = "aws:SecureTransport"
    }

    resources = [
      "${var.s3_bucket_arn}/*",
    ]
  }
}
