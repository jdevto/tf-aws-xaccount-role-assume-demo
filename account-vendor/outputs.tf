output "vendor_automation_role_arn" {
  description = "ARN of the vendor automation IAM role"
  value       = aws_iam_role.vendor_automation_role.arn
}

output "vendor_automation_role_name" {
  description = "Name of the vendor automation IAM role"
  value       = aws_iam_role.vendor_automation_role.name
}

output "instance_profile_name" {
  description = "Name of the EC2 instance profile (for EC2-based automation)"
  value       = aws_iam_instance_profile.vendor_automation_profile.name
}

output "instance_profile_arn" {
  description = "ARN of the EC2 instance profile"
  value       = aws_iam_instance_profile.vendor_automation_profile.arn
}

output "lambda_execution_role_arn" {
  description = "ARN of the Lambda execution role (for Lambda-based automation)"
  value       = aws_iam_role.lambda_execution_role.arn
}

output "assume_role_example" {
  description = "Example command to assume company role from vendor account"
  value       = "aws sts assume-role --role-arn ${local.company_role_arn} --role-session-name vendor-session --external-id ''"
}
