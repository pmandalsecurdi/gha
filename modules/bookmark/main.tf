terraform {
  required_providers {
    okta = {
      source = "okta/okta"
    }
  }
}

resource "okta_app_bookmark" "bookmark_apps" {
  for_each = { for app in var.apps : app.label => app }

  label = each.value.label
  url   = each.value.url
   logo = "${path.module}/${each.value.logo_path}"

}
