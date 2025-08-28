terraform {
  required_providers {
    okta = {
      source = "okta/okta"
    }
  }
}

resource "okta_app_saml" "saml_apps" {
  for_each = { for app in var.apps : app.label => app }

  label       = each.value.label
  status      = lookup(each.value, "status", "ACTIVE")
  sso_url     = each.value.acs_url
  recipient   = each.value.acs_url
  destination = each.value.acs_url
  audience    = each.value.audience

  # Let Okta decide if not specified
  subject_name_id_format = lookup(each.value, "subject_name_id_format", null)

  subject_name_id_template = coalesce(
    try(format("$${%s}", lookup(each.value, "subject_name_id_template", "user.email")), null),
    "$${user.email}"
  )

  user_name_template = try(
    replace(replace(lookup(each.value, "user_name_template", null), "{", ""), "}", ""),
    null
  )

  user_name_template_type = try(
    user_name_template != null ? "CUSTOM" : null,
    null
  )

  dynamic "attribute_statements" {
    for_each = lookup(each.value, "attribute_statements", [])
    content {
      type   = lookup(attribute_statements.value, "type", "EXPRESSION")
      name   = attribute_statements.value.name
      values = attribute_statements.value.values
    }
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      subject_name_id_format, # Ignore if Okta flips default
      user_name_template_type # Ignore if Okta flips CUSTOM <-> BUILT_IN
    ]
  }
}
