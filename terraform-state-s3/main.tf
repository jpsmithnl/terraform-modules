variable state_bucket_name       {} 
variable environment_tag         {}

resource "aws_kms_key" "state" {
  description             = "This key is used to encrypt state bucket objects"
  deletion_window_in_days = 10
}

resource "aws_kms_alias" "state" {
  name          = "alias/terraform-state"
  target_key_id = aws_kms_key.state.key_id
}

resource "aws_s3_bucket" "state" {
  bucket = var.state_bucket_name
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.state.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
  
  tags = {
    Name        = var.state_bucket_name
    Environment = var.environment_tag
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket = aws_s3_bucket.state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
