# Terraform execution container for Octopus Deploy

Octopus execution container image based on `octopuslabs/workertools`, containing:

- Terraform CLI (`TERRAFORM_VERSION` build arg)
- An offline filesystem mirror of the Octopus Deploy provider (`OCTOPUS_PROVIDER_VERSION` build arg) in `/opt/terraform/providers`
- `TF_CLI_CONFIG_FILE=/etc/terraform.rc`, which makes Terraform install providers only from that mirror

Providers are downloaded at image build time (GitHub Actions has internet access), so workers
in an air-gapped environment can run `terraform init` without reaching the registry.

Only providers listed in `mirror/providers.tf.tmpl` are available. A provider or version not in the mirror
makes `terraform init` fail immediately rather than attempting a download.

Note: this uses Terraform (registry.terraform.io), not OpenTofu.

## Build locally

    docker build -t octopus-terraform \
      --build-arg TERRAFORM_VERSION=1.7.2 \
      --build-arg OCTOPUS_PROVIDER_VERSION=1.19.0 \
      terraform-execution-container

## Verify offline

    docker run --rm --network none -v "$PWD/terraform-execution-container/test:/work" -w /work octopus-terraform terraform init

## Using it in Octopus

Push the image to a registry the worker can reach, add it as a Docker feed, and set the step's
execution container to this image. The worker still needs network access to the Octopus Server and
your Terraform state backend.
