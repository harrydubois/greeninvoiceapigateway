resource "aws_kms_key" "sqs_kms_key" {
  description = "SQS KMS key"
}

resource "aws_kms_alias" "sqs_kms_alias" {
  name          = "alias/greendev/terraform/sqs"
  target_key_id = aws_kms_key.sqs_kms_key.id
}

resource "aws_kms_key" "s3_kms_key" {
  description = "S3 KMS key"
}

resource "aws_kms_alias" "s3_kms_alias" {
  name          = "alias/greendev/terraform/s3"
  target_key_id = aws_kms_key.s3_kms_key.id
}

#######
# IAM #
#######

data "aws_iam_policy_document" "sqs_kms_use" {
  statement {
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]
    resources = [
      "${aws_kms_key.sqs_kms_key.arn}"
    ]
  }
}

resource "aws_iam_policy" "sqs_kms_use" {
    name = "sqsKMSUse"
    description = "Policy to allow use of SQS KMS key"
    policy = "${data.aws_iam_policy_document.sqs_kms_use.json}"
}

resource "aws_iam_role_policy_attachment" "sqs_kms_policy_attachment" {
    role = aws_iam_role.lambda_to_sqs_execution_role.name
    policy_arn = aws_iam_policy.sqs_kms_use.arn
}


data "aws_iam_policy_document" "s3_kms_use" {
  statement {
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]
    resources = [
      "${aws_kms_key.s3_kms_key.arn}"
    ]
  }
}

resource "aws_iam_policy" "s3_kms_use" {
    name = "s3KMSUse"
    description = "Policy to allow use of S3 KMS key"
    policy = "${data.aws_iam_policy_document.s3_kms_use.json}"
}

resource "aws_iam_role_policy_attachment" "s3_kms_policy_attachment" {
    role = aws_iam_role.sqs_to_s3_execution_role.name
    policy_arn = aws_iam_policy.s3_kms_use.arn
}

resource "aws_iam_role_policy_attachment" "sqs_s3_kms_policy_attachment" {
    role = aws_iam_role.sqs_to_s3_execution_role.name
    policy_arn = aws_iam_policy.sqs_kms_use.arn
}
