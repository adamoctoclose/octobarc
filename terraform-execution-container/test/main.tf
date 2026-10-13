# Used by CI to prove `terraform init` works with no network access.
terraform {
  required_providers {
    octopusdeploy = {
      source = "OctopusDeploy/octopusdeploy"
    }
  }
}
