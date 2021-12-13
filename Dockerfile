# Managed AWS OTel Lambda layer
FROM public.ecr.aws/cds-snc/opentelemetry-python-lambda:1.7.1 as otel

FROM public.ecr.aws/lambda/python:3.8

COPY --from=otel /opt /opt

COPY lambda.py ${LAMBDA_TASK_ROOT}

CMD [ "lambda.handler" ]
