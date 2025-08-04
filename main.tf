terraform {
  required_providers {
    okta = {
      source  = "okta/okta"
      version = "~> 3.35"
    }
  }
}

provider "okta" {
  org_name  = local.okta_org_name
  base_url  = local.okta_base_url
  api_token = local.okta_api_token
}

locals {
  apps_data     = yamldecode(file("${path.module}/apps.yaml"))
  apps_oidc     = try(local.apps_data.oidc, [])
  apps_saml     = try(local.apps_data.saml, [])
  apps_swa      = try(local.apps_data.swa, [])
  apps_bookmark = try(local.apps_data.bookmark, [])
}

module "oidc" {
  source = "./modules/oidc"
  apps   = local.apps_oidc
}

module "saml" {
  source = "./modules/saml"
  apps   = local.apps_saml
}

module "swa" {
  source = "./modules/swa"
  apps   = local.apps_swa
}

module "bookmark" {
  source = "./modules/bookmark"
  apps   = local.apps_bookmark
}
