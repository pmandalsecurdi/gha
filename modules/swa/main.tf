terraform {
  required_providers {
    okta = {
      source = "okta/okta"
    }
  }
}

resource "okta_app_swa" "swa_apps" {
  for_each = { for app in var.apps : app.label => app }

  label           = each.value.label
  url             = each.value.url
  username_field  = try(each.value.username_field, "txtbox-username")
  password_field  = try(each.value.password_field, "txtbox-password")
  button_field    = try(each.value.button_field, "btn-login")
  user_name_template       = "$${source.login}"
  user_name_template_type  = "BUILT_IN"
  logo = "${path.root}/${each.value.logo_path}"
  lifecycle {
    prevent_destroy = true
}
}
