# tf-aws-xaccount-role-assume-demo

Terraform demo showcasing cross-account IAM role delegation using STS AssumeRole. This demonstrates the secure way to allow a vendor's automation tool (running in their AWS account) to temporarily access resources in your AWS account without sharing IAM user credentials.

---

## 🔧 Overview

This demo implements **Option A** - the most secure cross-account access pattern:

* **Account Company** creates an IAM role (`VendorAccessRole`) with a trust policy that allows a specific role from the vendor's account to assume it.
* **Account Vendor** has an automation role (`VendorAutomationRole`) that can assume the company's role to get temporary credentials.

```plaintext
┌─────────────────────┐        AssumeRole        ┌────────────────────────┐
│ Vendor AWS Account  │ ───────────────────────▶ │ Company AWS Account    │
│ 222222222222        │                         │ 111111111111           │
│  IAM Role:          │                         │  IAM Role:             │
│  VendorAutomationRole│                        │  VendorAccessRole      │
└─────────────────────┘                         │  (trusted entity =     │
                                                │   VendorAutomationRole)│
                                                └────────────────────────┘
```

### 🎯 Scenario Setup

| Entity | AWS Account | Description |
|--------|-------------|-------------|
| Company | 111111111111 | Owns the AWS resources (S3, EC2, etc.) |
| Vendor | 222222222222 | Runs an automated tool from their own AWS account |

### 🔐 Security Characteristics

✅ **No IAM users or long-term keys shared**
✅ **Access is fully auditable via CloudTrail**
✅ **Least privilege is enforced via IAM policy**
✅ **Role can be revoked instantly by removing trust or policy**

---

## 🚀 Deployment Steps

### Prerequisites

1. Two AWS accounts (Company and Vendor)
2. AWS CLI configured with credentials for both accounts
3. Terraform >= 1.0 installed

### ✅ Step 1: Deploy Base Resources in Account Company

Create a `terraform.tfvars` file in `./account-company/`:

```hcl
aws_region        = "ap-southeast-2"
vendor_account_id = "222222222222"
company_role_name = "VendorAccessRole"
enable_s3_access  = true
```

Apply the initial setup:

```bash
terraform -chdir=./account-company init
terraform -chdir=./account-company apply \
  -target=random_string.suffix \
  -target=aws_iam_role.vendor_access_role
```

Note the output `vendor_access_role_arn` - you'll need this for the vendor account.

---

### ✅ Step 2: Deploy Base Resources in Account Vendor

Create a `terraform.tfvars` file in `./account-vendor/`:

```hcl
aws_region        = "ap-southeast-2"
company_account_id = "111111111111"
company_role_name  = "VendorAccessRole"
vendor_role_name   = "VendorAutomationRole"
company_role_arn   = "arn:aws:iam::111111111111:role/VendorAccessRole"  # From Step 1 output
```

Apply the initial setup:

```bash
terraform -chdir=./account-vendor init
terraform -chdir=./account-vendor apply \
  -target=aws_iam_role.vendor_automation_role \
  -target=aws_iam_instance_profile.vendor_automation_profile
```

---

### ✅ Step 3: Finalize Setup in Account Company

```bash
terraform -chdir=./account-company apply
```

This will create the S3 bucket (if enabled) and attach the permissions policy to the role.

---

### ✅ Step 4: Finalize Setup in Account Vendor

```bash
terraform -chdir=./account-vendor apply
```

This will attach the assume role policy to the vendor automation role.

---

## 🧪 Testing the Setup

### Test 1: Assume Role from Vendor Account

From the vendor account, use the AWS CLI to assume the company's role:

```bash
# Get temporary credentials
aws sts assume-role \
  --role-arn arn:aws:iam::111111111111:role/VendorAccessRole \
  --role-session-name vendor-session

# The output will contain:
# - AccessKeyId
# - SecretAccessKey
# - SessionToken
```

### Test 2: Use Temporary Credentials

Export the temporary credentials and test S3 access:

```bash
export AWS_ACCESS_KEY_ID=<AccessKeyId>
export AWS_SECRET_ACCESS_KEY=<SecretAccessKey>
export AWS_SESSION_TOKEN=<SessionToken>

# List the company's S3 bucket
aws s3 ls s3://company-data-bucket-<suffix>/

# Try to upload (should fail - read-only access)
aws s3 cp test.txt s3://company-data-bucket-<suffix>/  # Should fail
```

### Test 3: Verify CloudTrail Logging

Check CloudTrail in the company account to see the `AssumeRole` API call:

```bash
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=AssumeRole \
  --max-results 10
```

---

## 📋 What Gets Created

### Account Company

* **IAM Role** (`VendorAccessRole`): Role that vendor can assume
  * Trust policy allows `VendorAutomationRole` from vendor account
  * Permissions policy grants S3 read-only access (if enabled)
* **S3 Bucket** (optional): Demo bucket for testing vendor access
  * Versioning enabled
  * Encryption enabled
  * Public access blocked

### Account Vendor

* **IAM Role** (`VendorAutomationRole`): Role for vendor automation
  * Can be assumed by EC2 and Lambda services
  * Has policy to assume company's `VendorAccessRole`
* **Instance Profile**: For EC2-based automation
* **Lambda Execution Role**: For Lambda-based automation

---

## 🔍 Key Files

```plaintext
.
├── account-company/          # Company account resources
│   ├── main.tf              # IAM role and S3 bucket
│   ├── variables.tf         # Input variables
│   ├── outputs.tf          # Output values
│   └── versions.tf         # Provider configuration
│
├── account-vendor/           # Vendor account resources
│   ├── main.tf              # Automation role and policies
│   ├── variables.tf         # Input variables
│   ├── outputs.tf           # Output values
│   └── versions.tf         # Provider configuration
│
└── README.md                # This file
```

---

## 🛡️ Security Best Practices

1. **Least Privilege**: The vendor role only has the minimum permissions needed (S3 read-only in this demo)
2. **Audit Trail**: All `AssumeRole` calls are logged in CloudTrail
3. **No Long-term Credentials**: Only temporary credentials are used
4. **Revocable**: Remove the trust policy or permissions policy to instantly revoke access
5. **External ID** (optional): Can be added to trust policy for additional security

---

## 📚 References

* [AWS IAM Roles for Cross-Account Access](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_common-scenarios_aws-accounts.html)
* [AWS STS AssumeRole API](https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRole.html)
* [Cross-Account Access Patterns](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_common-scenarios.html)

---

## 📝 License

MIT License
