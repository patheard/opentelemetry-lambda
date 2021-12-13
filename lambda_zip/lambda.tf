#
# Lambda: zip
#
locals {
  # Layer ARN from https://aws-otel.github.io/docs/getting-started/lambda/lambda-python
  otel_layer_arn = "arn:aws:lambda:ca-central-1:901920570463:layer:aws-otel-python38-ver-1-7-1:1"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "lambda.py"
  output_path = "/tmp/lambda.py.zip"
}

resource "aws_lambda_function" "lambda_zip" {
  filename      = "/tmp/lambda.py.zip"
  function_name = "lambda_zip"
  handler       = "lambda.handler"
  runtime       = "python3.8"
  timeout       = 10 
  role          = aws_iam_role.lambda.arn

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  layers = [ 
    local.otel_layer_arn
  ]

  environment {
    variables = {
      AWS_LAMBDA_EXEC_WRAPPER = "/opt/otel-instrument"
    }
  }

  tracing_config {
    mode = "Active"
  }

  tags = {
    CostCentre = "Platform"
    Terraform  = true
  }
}
