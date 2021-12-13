resource "aws_lambda_function" "api_lambda" {
  function_name = "lambda_api"
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.lambda.repository_url}:latest"
  timeout       = 10
  role          = aws_iam_role.lambda.arn

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
