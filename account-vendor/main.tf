# IAM Role for Vendor Automation
resource "aws_iam_role" "vendor_automation_role" {
  name = var.vendor_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "ec2.amazonaws.com",
            "lambda.amazonaws.com"
          ]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "Vendor Automation Role"
    Description = "Role used by vendor automation tools to assume company roles"
  }
}

# Policy allowing this role to assume the company's role
resource "aws_iam_role_policy" "assume_company_role_policy" {
  name = "AssumeCompanyRolePolicy"
  role = aws_iam_role.vendor_automation_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = local.company_role_arn
      }
    ]
  })
}

# Optional: EC2 Instance Profile for running automation on EC2
resource "aws_iam_instance_profile" "vendor_automation_profile" {
  name = "${var.vendor_role_name}-instance-profile"
  role = aws_iam_role.vendor_automation_role.name

  tags = {
    Name = "Vendor Automation Instance Profile"
  }
}

# Optional: Lambda execution role (if using Lambda for automation)
resource "aws_iam_role" "lambda_execution_role" {
  name = "${var.vendor_role_name}-lambda-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "Lambda Execution Role for Vendor Automation"
  }
}

# Basic Lambda execution permissions (CloudWatch Logs)
resource "aws_iam_role_policy" "lambda_basic_execution" {
  name = "LambdaBasicExecutionPolicy"
  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Allow Lambda execution role to assume the automation role
resource "aws_iam_role_policy" "lambda_assume_automation_role" {
  name = "AssumeAutomationRolePolicy"
  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = aws_iam_role.vendor_automation_role.arn
      }
    ]
  })
}
