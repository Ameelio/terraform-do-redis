# ################################################################################
# Configures resource providers for use with terraform.
# If you change this file, make should run terraform init -chdir='terraform'
# ################################################################################

terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }

    local = {
      source  = "hashicorp/local"
      version = ">= 2.4.0"
    }

    # Floor, not pin: consumers pick the exact version. The _v1 resource
    # names used in main.tf exist since 2.7.
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.7"
    }

  }

  # ">= floor" rather than "~>": a pessimistic pin here fences every consumer's
  # terraform core version (ameelio-infrastructure hit this moving to 1.16).
  required_version = ">= 1.14.0"
}
