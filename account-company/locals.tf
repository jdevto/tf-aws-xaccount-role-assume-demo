locals {
  vendor_role_arn = "arn:aws:iam::${var.vendor_account_id}:role/${var.vendor_role_name}"

  s3_bucket_name = var.s3_bucket_name != "" ? var.s3_bucket_name : "company-data-bucket-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}
