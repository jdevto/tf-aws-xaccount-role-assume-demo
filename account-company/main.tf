# IAM Role for Vendor Access
resource "aws_iam_role" "vendor_access_role" {
  name = var.company_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.vendor_account_id}:root"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "aws:PrincipalArn" = local.vendor_role_arn
          }
        }
      }
    ]
  })

  tags = {
    Name        = "Vendor Access Role"
    Description = "Allows vendor automation to assume this role for temporary access"
  }
}

# Permissions Policy for Vendor Role
resource "aws_iam_role_policy" "vendor_access_policy" {
  count = var.enable_s3_access ? 1 : 0
  name  = "VendorAccessPolicy"
  role  = aws_iam_role.vendor_access_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.company_data[0].arn,
          "${aws_s3_bucket.company_data[0].arn}/*"
        ]
      }
    ]
  })
}

# Optional S3 Bucket for Demo
resource "aws_s3_bucket" "company_data" {
  count  = var.enable_s3_access ? 1 : 0
  bucket = local.s3_bucket_name

  tags = {
    Name        = "Company Data Bucket"
    Description = "Demo bucket for vendor access"
  }
}

resource "aws_s3_bucket_versioning" "company_data" {
  count  = var.enable_s3_access ? 1 : 0
  bucket = aws_s3_bucket.company_data[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "company_data" {
  count  = var.enable_s3_access ? 1 : 0
  bucket = aws_s3_bucket.company_data[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "company_data" {
  count  = var.enable_s3_access ? 1 : 0
  bucket = aws_s3_bucket.company_data[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
