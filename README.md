# OpenTelemetry Lambda
Testing the [AWS OpenTelemetry managed Lambda layer](https://aws-otel.github.io/docs/getting-started/lambda/lambda-python).

# Tests
Each folder is as a separate test:
* `lambda_zip`: create a Lambda function from a zip archive.
* `lambda_docker`: create the same Lambda function as `lambda_zip`, but using a Docker image.
* `lambda_api`: API gateway invoking a Lambda function using Mangum + FastAPI.

:warning: &nbsp;The tests are meant to be created one at a time as they have overlapping AWS resource names.
