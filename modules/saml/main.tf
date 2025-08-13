terraform {
  required_providers {
    okta = {
      source = "okta/okta"
    }
  }
}

resource "okta_app_saml" "saml_apps" {
  for_each = { for app in var.apps : app.label => app }

  label                          = each.value.label
  status                         = try(each.value.status, "ACTIVE")
  sso_url                        = each.value.acs_url
  recipient                      = each.value.acs_url
  destination                    = each.value.acs_url
  audience                       = each.value.audience

  # SAML NameID template: plain EL (no ${})
  subject_name_id_template = try(
    replace(replace(each.value.subject_name_id_template, "{", ""), "}", ""),
    "user.email"
  )

  # App username template: ensure ${...} form if provided in YAML as "user.email"
  user_name_template = try(
    can(regex("^\\$\\{.*\\}$", each.value.user_name_template))
      ? each.value.user_name_template
      : format("$${%s}", replace(replace(each.value.user_name_template, "{", ""), "}", "")),
    null
  )
  # Keep type stable if you set a custom template
  user_name_template_type        = try(each.value.user_name_template != null ? "CUSTOM" : null, null)

  subject_name_id_format         = try(each.value.subject_name_id_format, "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress")
  user_name_template_push_status = try(each.value.user_name_template_push_status, "PUSH")
  response_signed                = try(each.value.response_signed, true)
  assertion_signed               = try(each.value.assertion_signed, true)
  signature_algorithm            = try(each.value.signature_algorithm, "RSA_SHA256")
  digest_algorithm               = try(each.value.digest_algorithm, "SHA256")
  authn_context_class_ref        = try(each.value.authn_context_class_ref, "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport")

  dynamic "attribute_statements" {
    for_each = try(each.value.attribute_statements, [])
    content {
      type   = "EXPRESSION"
      name   = attribute_statements.value.name
      values = attribute_statements.value.values
    }
  }
}
