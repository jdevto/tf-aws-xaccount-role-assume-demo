output "vendor_access_role_arn" {
  description = "ARN of the IAM role that vendor can assume"
  value       = aws_iam_role.vendor_access_role.arn
}

output "assume_role_command" {
  description = "Example AWS CLI command for vendor to assume the role"
  value       = "aws sts assume-role --role-arn ${aws_iam_role.vendor_access_role.arn} --role-session-name vendor-session"
}
