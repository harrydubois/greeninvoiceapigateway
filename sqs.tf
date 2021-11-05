resource "aws_sqs_queue" "sqsqueue" {
  name = "green-invoice-queue"

  kms_master_key_id = "alias/greendev/terraform/sqs"
  kms_data_key_reuse_period_seconds = 600
}