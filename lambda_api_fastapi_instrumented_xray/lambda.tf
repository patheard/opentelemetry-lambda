locals {
  # Layer ARN from https://aws-otel.github.io/docs/getting-started/lambda/lambda-python
  otel_layer_arn = "arn:aws:lambda:ca-central-1:901920570463:layer:aws-otel-python38-ver-1-7-1:1"
}

data "archive_file" "lambda_zip" {
  source_dir  = "src/dist"
  output_path = "/tmp/lambda.zip"
  type        = "zip"

  depends_on = [
    null_resource.lambda_build
  ]
}

resource "aws_lambda_function" "api_lambda" {
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  function_name = "lambda_api"
  handler       = "lambda.handler"
  runtime       = "python3.8"
  timeout       = 60
  role          = aws_iam_role.lambda.arn

  layers = [
    local.otel_layer_arn
  ]

  environment {
    variables = {
      AWS_LAMBDA_EXEC_WRAPPER             = "/opt/otel-instrument"
      OPENTELEMETRY_COLLECTOR_CONFIG_FILE = "/var/task/collector.yaml"
      OTEL_BSP_MAX_EXPORT_BATCH_SIZE      = 1
      OTEL_TRACES_SAMPLER                 = "Always_on"
      OTEL_PYTHON_ID_GENERATOR            = "xray"
      OTEL_PROPAGATORS                    = "xray"
      OTEL_EXPORTER_OTLP_ENDPOINT         = "127.0.0.1:4317"
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

resource "null_resource" "lambda_build" {
  triggers = {
    handler      = base64sha256(file("src/lambda.py"))
    config       = base64sha256(file("src/collector.yaml"))
    requirements = base64sha256(file("src/requirements.txt"))
    build        = base64sha256(file("src/build.sh"))
  }

  provisioner "local-exec" {
    command = "${path.module}/src/build.sh"
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
