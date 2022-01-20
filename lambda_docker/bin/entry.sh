#!/bin/bash

if [ -z "${AWS_LAMBDA_RUNTIME_API}" ]; then
    echo "Running aws-lambda-rie"
    exec find . -name "*.py" | entr -r /usr/bin/aws-lambda-rie /usr/local/bin/python -m awslambdaric "$1"
else
    if [ -z "$AWS_LAMBDA_EXEC_WRAPPER" ]; then
        exec /usr/local/bin/python -m awslambdaric "$1"
    else
        exec -- "$AWS_LAMBDA_EXEC_WRAPPER" /usr/local/bin/python -m awslambdaric "$1"
    fi
fi