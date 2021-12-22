FROM python:3.8-slim-buster

# Define function directory
ARG FUNCTION_DIR="/function"

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    ca-certificates \
    curl \
    git \
    gstreamer1.0-libav \
    libnss3-tools \
    libatk-bridge2.0-0 \
    libcups2-dev \
    libxkbcommon-x11-0 \
    libxcomposite-dev \
    libxrandr2 \
    libgbm-dev \
    libgtk-3-0 \
    libxshmfence-dev \
    gnupg2 \
    postgresql-client \
    openssh-client \
    python3-pip \
    unzip \
    vim \
    wget \
    xz-utils \
    zsh \
    entr \
    && apt-get autoremove -y \
    && apt-get clean -y

WORKDIR ${FUNCTION_DIR}

RUN mkdir -p /pymodules

ENV PYTHONPATH=/pymodules
ENV LAMBDA_RUNTIME_DIR=/pymodules

COPY ./requirements.txt ${FUNCTION_DIR}

COPY ./otel-layer.zip /tmp/otel-layer.zip
RUN unzip /tmp/otel-layer.zip -d /opt && rm /tmp/otel-layer.zip

RUN python3.8 -m pip install -r ${FUNCTION_DIR}/requirements.txt --target /pymodules

# Install the runtime interface client
RUN pip install --target /pymodules \
    awslambdaric

# Copy function code
COPY . ${FUNCTION_DIR}

# Set build variables
ARG git_sha
ENV GIT_SHA=$git_sha

# Install lambda runtime interactive environment
ARG RIE_VERSION=1.1
ARG AWS_RIE_SRC=https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/download
RUN wget -O aws-lambda-rie ${AWS_RIE_SRC}/${RIE_VERSION}/aws-lambda-rie \
    && mv aws-lambda-rie /usr/bin/aws-lambda-rie

COPY bin/entry.sh /
RUN chmod 755 /usr/bin/aws-lambda-rie /entry.sh

# COPY --from=amazon/aws-lambda-python:3.8 /var/runtime /var/runtime

ENTRYPOINT [ "/entry.sh" ]
CMD [ "lambda.handler" ]
