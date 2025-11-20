variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "ap-southeast-2"
}

variable "company_account_id" {
  description = "AWS Account ID of the company account"
  type        = string
}

variable "company_role_name" {
  description = "Name of the IAM role in company account to assume"
  type        = string
  default     = "VendorAccessRole"
}

variable "vendor_role_name" {
  description = "Name of the IAM role in vendor account for automation"
  type        = string
  default     = "VendorAutomationRole"
}

variable "company_role_arn" {
  description = "ARN of the company role (output from company account deployment)"
  type        = string
  default     = ""
}
