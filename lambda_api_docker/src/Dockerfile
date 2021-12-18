FROM alpine:latest as zipper

RUN mkdir -p /tmp/otel

WORKDIR /tmp/otel

COPY layers/collector.zip .
COPY layers/otel.zip .

RUN unzip collector.zip \
    && unzip otel.zip \
    && rm *.zip

FROM public.ecr.aws/lambda/python:3.8

# API dependencies
COPY requirements.txt .
RUN  pip3 install -r requirements.txt --target "${LAMBDA_TASK_ROOT}"

# API code
COPY lambda.py ${LAMBDA_TASK_ROOT}

# OTel collector and Pyton instrumentation layers
COPY --from=zipper /tmp/otel/ /opt/

CMD [ "lambda.handler" ]