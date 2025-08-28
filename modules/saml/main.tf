terraform {
  required_providers {
    okta = {
      source = "okta/okta"
    }
  }
}

resource "okta_app_saml" "saml_apps" {
  for_each = { for app in var.apps : app.label => app }

  # ...other args...

  # Optional template (normalized)
  user_name_template = try(
    trim(replace(replace(lookup(each.value, "user_name_template", null), "{", ""), "}", "")),
    null
  )

  # Only set type when a non-empty template is provided; otherwise omit
  user_name_template_type = try(
    trim(replace(replace(lookup(each.value, "user_name_template", ""), "{", ""), "}", "")) == "" ? null : "CUSTOM",
    null
  )

  # Let Okta decide if not specified
  subject_name_id_format = lookup(each.value, "subject_name_id_format", null)

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      subject_name_id_format,
      user_name_template_type,
    ]
  }
}
