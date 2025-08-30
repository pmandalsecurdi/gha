terraform {
  required_providers {
    okta = {
      source = "okta/okta"
    }
  }
}

resource "okta_app_oauth" "oidc_apps" {
  for_each = { for app in var.apps : app.label => app }

  label = each.value.label
  type  = lookup(each.value, "type", "web")

  token_endpoint_auth_method = coalesce(
    try(each.value.token_endpoint_auth_method, null),
    contains(["web", "service"], lookup(each.value, "type", "web")) ? "client_secret_post" : "none"
  )

  grant_types = coalesce(
    try(each.value.grant_types, null),
    lookup(each.value, "type", "web") == "service" ? ["client_credentials"] : ["authorization_code"]
  )

  response_types = coalesce(
    try(each.value.response_types, null),
    lookup(each.value, "type", "web") == "service" ? [] : ["code"]
  )

  redirect_uris             = lookup(each.value, "type", "web") == "service" ? [] : each.value.redirect_uris
  post_logout_redirect_uris = lookup(each.value, "type", "web") == "service" ? null : lookup(each.value, "post_logout_redirect_uris", null)
  login_uri                 = lookup(each.value, "login_uri", null)


  user_name_template_type = length(trimspace(try(each.value.user_name_template, ""))) > 0 ? "CUSTOM" : "BUILT_IN"

  omit_secret = contains(["browser", "native"], lookup(each.value, "type", "web")) ? true : null

  lifecycle {
    prevent_destroy = true
  }
}
