locals {
  create_policy = var.create_policy != null ? var.create_policy : var.policy != null
  ssm_name      = replace(var.name, "@", "_")
}

resource "aws_iam_user" "default" {
  name = "${var.name}${var.postfix ? "Account" : ""}"
  tags = var.tags
}

resource "aws_iam_access_key" "default" {
  user = aws_iam_user.default.name
}

resource "aws_iam_user_policy" "default" {
  count  = local.create_policy ? 1 : 0
  name   = "${var.name}${var.postfix ? "Policy" : ""}"
  user   = aws_iam_user.default.name
  policy = var.policy
}

resource "aws_iam_user_policy_attachment" "default" {
  for_each = var.policy_arns

  user       = aws_iam_user.default.name
  policy_arn = each.value
}

resource "aws_ssm_parameter" "access_key_id" {
  name   = "/${lower(local.ssm_name)}${var.postfix ? "account" : ""}/credentials/access_key_id"
  type   = "SecureString"
  value  = aws_iam_access_key.default.id
  key_id = var.kms_key_id
  tags   = var.tags
}

resource "aws_ssm_parameter" "secret_access_key" {
  name   = "/${lower(local.ssm_name)}${var.postfix ? "account" : ""}/credentials/secret_access_key"
  type   = "SecureString"
  value  = aws_iam_access_key.default.secret
  key_id = var.kms_key_id
  tags   = var.tags
}

resource "aws_ssm_parameter" "ses_smtp_password_v4" {
  count  = var.ssm_ses_smtp_password_v4 ? 1 : 0
  name   = "/${lower(local.ssm_name)}${var.postfix ? "account" : ""}/credentials/ses_smtp_password_v4"
  type   = "SecureString"
  value  = aws_iam_access_key.default.ses_smtp_password_v4
  key_id = var.kms_key_id
  tags   = var.tags
}
