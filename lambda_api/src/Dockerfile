# Managed AWS OTel Lambda layer
FROM public.ecr.aws/cds-snc/opentelemetry-python-lambda:1.7.1 as otel

FROM public.ecr.aws/lambda/python:3.8

# OpenTelemetry dependencies
COPY --from=otel /opt /opt

# API dependencies
COPY requirements.txt .
RUN  pip3 install -r requirements.txt --target "${LAMBDA_TASK_ROOT}"

# API code
COPY lambda.py ${LAMBDA_TASK_ROOT}

CMD [ "lambda.handler" ]
