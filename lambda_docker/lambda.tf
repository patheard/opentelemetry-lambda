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
