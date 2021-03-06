FROM mcr.microsoft.com/vscode/devcontainers/python:3.8-buster

ARG USERNAME=vscode

# Set these in devcontainer.json
ARG TERRAFORM_VERSION
ARG AWS_CLI_VERSION

# Install packages
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends build-essential ca-certificates curl git gnupg2 jq libffi-dev make openssh-client vim zsh \
    && apt-get autoremove -y && apt-get clean -y 

# Install Terraform
RUN curl -Lo terraform.zip https://releases.hashicorp.com/terraform/"${TERRAFORM_VERSION}"/terraform_"${TERRAFORM_VERSION}"_linux_"$(dpkg --print-architecture)".zip \
    && unzip terraform.zip \
    && mv terraform /usr/local/bin/ \
    && rm terraform.zip

# Install Checkov
RUN pip3 install --upgrade requests setuptools \
    && pip3 install --upgrade botocore checkov

RUN curl -sL https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip -o awscliv2.zip
RUN unzip awscliv2.zip
RUN aws/install
RUN rm -rf \
    awscliv2.zip \
    aws \
    /usr/local/aws-cli/v2/*/dist/aws_completer \
    /usr/local/aws-cli/v2/*/dist/awscli/data/ac.index \
    /usr/local/aws-cli/v2/*/dist/awscli/examples
    
# Setup aliases and autocomplete
RUN echo "\n\
complete -C /usr/bin/aws_completer aws\n\
complete -C /usr/local/bin/terraform terraform\n\
alias tf='terraform'\n\
alias ll='la -la'" >> /home/"${USERNAME}"/.zshrc