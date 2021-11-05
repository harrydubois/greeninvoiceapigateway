####################
# Lambda Functions #
####################

resource "aws_lambda_function" "api_to_sqs" {
  function_name = "api_to_sqs"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_bucket_object.api_to_sqs.id

  runtime = "python3.9"
  handler = "api_to_sqs.lambda_handler"

  source_code_hash = data.archive_file.api_to_sqs.output_base64sha256

  role = aws_iam_role.lambda_to_sqs_execution_role.arn

  ### Passes the SQS queue URL to our function as a variable
  environment {
    variables = {
      QUEUE_URL = aws_sqs_queue.sqsqueue.id
    }
  }
}

resource "aws_lambda_function" "sqs_to_s3" {
  function_name = "sqs_to_s3"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_bucket_object.sqs_to_s3.id

  runtime = "python3.9"
  handler = "sqs_to_s3.lambda_handler"

  source_code_hash = data.archive_file.sqs_to_s3.output_base64sha256

  role = aws_iam_role.sqs_to_s3_execution_role.arn

  environment {
    variables = {
      S3_BUCKET = aws_s3_bucket.message_bucket.id
      QUEUE_URL = aws_sqs_queue.sqsqueue.id
    }
  }
}

### Trigger S3 Writer Lambda from SQS
resource "aws_lambda_event_source_mapping" "sqs_to_lambda_mapping" {
  event_source_arn = aws_sqs_queue.sqsqueue.arn
  function_name    = aws_lambda_function.sqs_to_s3.arn
  enabled          = true
  batch_size       = 1
}

### Log groups for our functions
resource "aws_cloudwatch_log_group" "api_to_sqs" {
  name = "/aws/lambda/${aws_lambda_function.api_to_sqs.function_name}"

  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "sqs_to_s3" {
  name = "/aws/lambda/${aws_lambda_function.sqs_to_s3.function_name}"

  retention_in_days = 30
}

#######
# IAM #
#######

resource "aws_iam_role_policy_attachment" "lambda_to_sqs_basic_execution_attachment" {
  role       = aws_iam_role.lambda_to_sqs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "sqs_to_s3_basic_execution_attachment" {
  role       = aws_iam_role.sqs_to_s3_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role" "lambda_to_sqs_execution_role" {
  name = "LambdaSQSWriteRole"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]

  })

  inline_policy {
    name = "LambdaSQSWritePolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Action   = "sqs:SendMessage"
        Effect   = "Allow"
        Resource = "${aws_sqs_queue.sqsqueue.arn}"
      }]
    })
  }
}

resource "aws_iam_role" "sqs_to_s3_execution_role" {
  name = "LambdaSQSReadDeleteS3WriteRole"
  assume_role_policy = jsonencode({

    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]

  })

  inline_policy {
    name = "lambda_sqs_read_delete_message_policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
          Effect   = "Allow"
          Resource = "${aws_sqs_queue.sqsqueue.arn}"
        }
      ]
    })
  }

  inline_policy {
    name = "lambda_s3_put_object_policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["s3:PutObject"]
          Effect   = "Allow"
          Resource = "${aws_s3_bucket.message_bucket.arn}/*"
        }
      ]
    })
  }
}

