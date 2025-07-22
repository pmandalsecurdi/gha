terraform {
  required_providers {
    okta = {
      source  = "okta/okta"
      version = "5.2"
    }
  }
}

provider "okta" {
  org_name  = var.okta_org_name
  base_url  = var.okta_base_url
  api_token = var.okta_api_token
}


locals {
  apps_data     = yamldecode(file("${path.module}/apps.yaml"))
  apps_oidc     = try(local.apps_data.oidc, [])
  apps_saml     = try(local.apps_data.saml, [])
  apps_swa      = try(local.apps_data.swa, [])
  apps_bookmark = try(local.apps_data.bookmark, [])
}

# OIDC
resource "okta_app_oauth" "oidc_apps" {
  for_each = { for app in local.apps_oidc : app.label => app }

  label                      = each.value.label
  type                       = try(each.value.type, "web")
  redirect_uris              = each.value.redirect_uris
  grant_types                = try(each.value.grant_types, ["authorization_code"])
  response_types             = try(each.value.response_types, ["code"])
  token_endpoint_auth_method = try(each.value.token_endpoint_auth_method, "client_secret_post")
  login_uri                  = try(each.value.login_uri, null)
  post_logout_redirect_uris  = try(each.value.post_logout_redirect_uris, null)

  user_name_template_type = "BUILT_IN"
  user_name_template      = "$${source.login}"
}

# SAML
resource "okta_app_saml" "saml_apps" {
  for_each = { for app in local.apps_saml : app.label => app }

  label                          = each.value.label
  status                         = "ACTIVE"
  sso_url                        = each.value.acs_url
  recipient                      = each.value.acs_url
  destination                    = each.value.acs_url
  audience                       = each.value.audience
  subject_name_id_template       = try(each.value.subject_name_id_template, "$${user.email}")
  user_name_template             = try(each.value.user_name_template, "$${user.email}")
  subject_name_id_format         = try(each.value.subject_name_id_format, "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress")
  user_name_template_push_status = try(each.value.user_name_template_push_status, "PUSH")
  response_signed                = try(each.value.response_signed, true)
  assertion_signed               = try(each.value.assertion_signed, true)
  signature_algorithm            = try(each.value.signature_algorithm, "RSA_SHA256")
  digest_algorithm               = try(each.value.digest_algorithm, "SHA256")
  authn_context_class_ref        = try(each.value.authn_context_class_ref, null)

  dynamic "attribute_statements" {
    for_each = try(each.value.attribute_statements, [])
    content {
      type   = "EXPRESSION"
      name   = attribute_statements.value.name
      values = attribute_statements.value.values
    }
  }
}

# SWA
resource "okta_app_swa" "swa_apps" {
  for_each = { for app in local.apps_swa : app.label => app }

  label          = each.value.label
  url            = each.value.url
  username_field = try(each.value.username_field, "txtbox-username")
  password_field = try(each.value.password_field, "txtbox-password")
  button_field   = try(each.value.button_field, "btn-login")

  user_name_template      = "$${source.login}"
  user_name_template_type = "BUILT_IN"
}

# Bookmark
resource "okta_app_bookmark" "bookmark_apps" {
  for_each = { for app in local.apps_bookmark : app.label => app }

  label = each.value.label
  url   = each.value.url
}

# Logging
resource "local_file" "app_log" {
  for_each = merge(
    { for k, v in okta_app_oauth.oidc_apps : k => {
      id    = v.id,
      type  = "OIDC",
      extra = "ClientID=${v.client_id} ClientSecret=${v.client_secret}"
    }},
    { for k, v in okta_app_saml.saml_apps : k => {
      id    = v.id,
      type  = "SAML",
      extra = "MetadataURL=${v.metadata_url}"
    }},
    { for k, v in okta_app_swa.swa_apps : k => {
      id    = v.id,
      type  = "SWA",
      extra = ""
    }},
    { for k, v in okta_app_bookmark.bookmark_apps : k => {
      id    = v.id,
      type  = "BOOKMARK",
      extra = ""
    }}
  )
  content  = "[${each.value.type}] ${each.key} - ID: ${each.value.id} - Status: SUCCESS - ${each.value.extra}"
  filename = "${path.module}/output/app_log_${each.key}.txt"
}

output "apps_created" {
  value = {
    oidc     = keys(okta_app_oauth.oidc_apps)
    saml     = keys(okta_app_saml.saml_apps)
    swa      = keys(okta_app_swa.swa_apps)
    bookmark = keys(okta_app_bookmark.bookmark_apps)
  }
}
