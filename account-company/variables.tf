variable "vendor_account_id" {
  description = "AWS Account ID of the vendor account"
  type        = string
}

variable "vendor_role_name" {
  description = "Name of the IAM role in vendor account that will assume this role"
  type        = string
  default     = "VendorAutomationRole"
}

variable "company_role_name" {
  description = "Name of the IAM role in company account for vendor access"
  type        = string
  default     = "VendorAccessRole"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for vendor access (optional, for demo purposes)"
  type        = string
  default     = ""
}

variable "enable_s3_access" {
  description = "Whether to grant S3 read-only access to the vendor role"
  type        = bool
  default     = true
}
