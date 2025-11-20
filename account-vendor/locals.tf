locals {
  company_role_arn = var.company_role_arn != "" ? var.company_role_arn : "arn:aws:iam::${var.company_account_id}:role/${var.company_role_name}"
}
