ARG BASE_IMAGE=octopuslabs/workertools
ARG BASE_TAG=latest
FROM ${BASE_IMAGE}:${BASE_TAG}

LABEL org.opencontainers.image.source="https://github.com/adamoctoclose/octobarc"
LABEL org.opencontainers.image.description="Octopus execution container with Terraform and an offline Octopus Deploy provider mirror"

ARG DEBIAN_FRONTEND=noninteractive
ARG TERRAFORM_VERSION=1.7.2
ARG OCTOPUS_PROVIDER_VERSION=1.19.0

# Get Terraform
# https://developer.hashicorp.com/terraform/downloads
RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null && \
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list && \
    apt-get update && apt-get install -y terraform=${TERRAFORM_VERSION}-1 && \
    rm -rf /var/lib/apt/lists/*

# Build time only (needs internet): download the Octopus provider into a
# filesystem mirror so `terraform init` works on air-gapped workers.
COPY mirror/providers.tf.tmpl /tmp/mirror/providers.tf.tmpl
RUN mkdir -p /tmp/mirror /opt/terraform/providers && \
    sed "s/__OCTOPUS_PROVIDER_VERSION__/${OCTOPUS_PROVIDER_VERSION}/" /tmp/mirror/providers.tf.tmpl > /tmp/mirror/providers.tf && \
    cd /tmp/mirror && \
    terraform providers mirror -platform=linux_amd64 /opt/terraform/providers && \
    rm -rf /tmp/mirror && \
    chmod -R a+rX /opt/terraform/providers

# Only install providers from the mirror; never contact the registry.
# An env var is used (rather than ~/.terraformrc) because Octopus controls the
# user and home directory inside execution containers.
COPY terraform.rc /etc/terraform.rc
ENV TF_CLI_CONFIG_FILE=/etc/terraform.rc
