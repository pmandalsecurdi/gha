terraform {
  required_providers {
    okta = {
      source = "okta/okta"
    }
  }
}

resource "okta_app_oauth" "oidc_apps" {
  for_each = { for app in var.apps : app.label => app }

  label                        = each.value.label
  type                         = try(each.value.type, "web")
  redirect_uris               = each.value.redirect_uris
  grant_types                 = try(each.value.grant_types, ["authorization_code"])
  response_types              = try(each.value.response_types, ["code"])
  token_endpoint_auth_method  = try(each.value.token_endpoint_auth_method, "client_secret_post")
  login_uri                   = try(each.value.login_uri, null)
  post_logout_redirect_uris  = try(each.value.post_logout_redirect_uris, null)
  user_name_template_type     = "BUILT_IN"
  user_name_template          = "$${source.login}"
}
