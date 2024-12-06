FROM jenkins/inbound-agent:latest

# Désactiver les invites interactives
ENV DEBIAN_FRONTEND=noninteractive

USER root
RUN apt-get update && apt-get install -y \
    software-properties-common \
    curl \
    unzip \
    git \
    python3-pip \
    docker.io \
    ansible \
    && rm -rf /var/lib/apt/lists/*

# Installer Terraform
ARG TERRAFORM_VERSION=1.6.0
RUN curl -fsSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip \
    && unzip terraform.zip -d /usr/local/bin/ \
    && rm terraform.zip

USER jenkins

WORKDIR /home/jenkins
