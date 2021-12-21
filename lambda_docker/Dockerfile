FROM amazon/aws-lambda-python:3.8

# Define function directory
ARG FUNCTION_DIR="/function"

RUN yum -y install \
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
    && yum -y autoremove \
    && yum clean all

WORKDIR ${FUNCTION_DIR}

RUN mkdir -p /pymodules
ENV PYTHONPATH=/pymodules
ENV PATH=/pymodules/bin:${PATH}

COPY ./requirements.txt ${FUNCTION_DIR}

COPY ./otel-layer.zip /tmp/otel-layer.zip
RUN unzip /tmp/otel-layer.zip -d /opt && rm /tmp/otel-layer.zip

RUN python3.8 -m pip install -r ${FUNCTION_DIR}/requirements.txt --target /pymodules

# Copy function code
COPY . ${FUNCTION_DIR}

# Set build variables
ARG git_sha
ENV GIT_SHA=$git_sha

CMD [ "lambda.handler" ]
