locals {
  # Layer ARN from https://aws-otel.github.io/docs/getting-started/lambda/lambda-python
  otel_layer_arn = "arn:aws:lambda:ca-central-1:901920570463:layer:aws-otel-python38-ver-1-7-1:1"
}

data "archive_file" "lambda_zip" {
  source_dir  = "src/dist"
  output_path = "/tmp/lambda.zip"
  type        = "zip"
}

resource "aws_lambda_function" "api_lambda" {
  filename      = "/tmp/lambda.zip"
  function_name = "lambda_api"
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


# Allow the API gateway to invoke this lambda function
resource "aws_lambda_permission" "api_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/*/*"
}
