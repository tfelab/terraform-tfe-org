terraform {
  required_version = ">= 0.12"

  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.58.1"
    }
  }
}

provider "tfe" {
  # Configuration options
  hostname = "app.terraform.io"
  token    = var.tfe_token
}
