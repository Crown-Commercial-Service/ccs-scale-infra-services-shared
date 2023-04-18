resource "aws_s3_bucket" "logging_s3_bucket" {
  bucket = "${var.logging_s3_bucket_name}-${var.environment}"

  grant {
    permissions = ["READ_ACP", "WRITE"]
    type        = "Group"
    uri         = "http://acs.amazonaws.com/groups/s3/LogDelivery"
  }

  grant {
    id          = data.aws_canonical_user_id.current_user.id
    type        = "CanonicalUser"
    permissions = ["READ_ACP", "WRITE_ACP", "WRITE", "READ"]
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name = "Agreements Service Pipeline Logging Bucket"
  }

  versioning {
    enabled = true
  }


}

resource "aws_s3_bucket" "terraform_state_s3_bucket" {
  acl    = "private"
  bucket = "${var.terraform_state_s3_bucket_name}-${var.environment}"

  tags = {
    Name = var.terraform_state_s3_bucket_name
  }

  logging {
    target_bucket = "${var.logging_s3_bucket_name}-${var.environment}"
    target_prefix = "logs/"
  }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "logging_s3_bucket_public_access_block" {
  bucket = aws_s3_bucket.logging_s3_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "terraform_state_s3_bucket_public_access_block" {
  bucket = aws_s3_bucket.terraform_state_s3_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
