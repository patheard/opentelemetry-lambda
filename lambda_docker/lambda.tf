#
# Lambda: Docker image
#
resource "aws_lambda_function" "lambda_docker" {
  function_name = "lambda_docker"
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.lambda.repository_url}:latest"
  timeout       = 10
  role          = aws_iam_role.lambda.arn

  environment {
    variables = {
      AWS_LAMBDA_EXEC_WRAPPER             = "/opt/otel-instrument"
      OPENTELEMETRY_COLLECTOR_CONFIG_FILE = "/function/collector.yaml"
      OTEL_BSP_MAX_EXPORT_BATCH_SIZE      = 1
      OTEL_TRACES_SAMPLER                 = "Always_on"
      OTEL_PYTHON_ID_GENERATOR            = "xray"
      OTEL_PROPAGATORS                    = "xray"
      OTEL_EXPORTER_OTLP_ENDPOINT         = "127.0.0.1:4317"
      OTEL_TRACES_EXPORTER                = "otlp"
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
  function_name = aws_lambda_function.lambda_docker.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/*/*"
}
