terraform {
  required_providers {
    okta = {
      source = "okta/okta"
    }
  }
}

resource "okta_app_saml" "saml_apps" {
  for_each = { for app in var.apps : app.label => app }

  # Required basics
  label       = each.value.label
  status      = lookup(each.value, "status", "ACTIVE")
  sso_url     = each.value.acs_url
  recipient   = each.value.acs_url
  destination = each.value.acs_url
  audience    = each.value.audience

  # NameID format + template (NameID MUST be an evaluated expression)
  subject_name_id_format = lookup(
    each.value,
    "subject_name_id_format",
    "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"
  )
  # YAML typically has: subject_name_id_template: "user.email"
  # Wrap it to ${user.email} for Okta to evaluate (escape $ for HCL)
  subject_name_id_template = coalesce(
    try(format("$${%s}", lookup(each.value, "subject_name_id_template", "user.email")), null),
    "$${user.email}"
  )

  # App username template:
  # Keep it OPTIONAL and PLAIN (e.g., "user.email"). Do NOT force ${...} here to avoid Okta "Invalid expression" errors.
  user_name_template = try(
    # tolerate {user.email} or ${user.email} in YAML by stripping braces
    replace(replace(lookup(each.value, "user_name_template", null), "{", ""), "}", ""),
    null
  )
  # If you want to force CUSTOM type only when a template is provided, uncomment:
  # user_name_template_type = user_name_template != null ? "CUSTOM" : null
  # lifecycle { ignore_changes = [user_name_template_type] }

  # Safer defaults (missing or null fall back)
  user_name_template_push_status = lookup(each.value, "user_name_template_push_status", null)
  response_signed                = coalesce(try(each.value.response_signed, null), true)
  assertion_signed               = coalesce(try(each.value.assertion_signed, null), true)
  signature_algorithm            = coalesce(try(each.value.signature_algorithm, null), "RSA_SHA256")
  digest_algorithm               = coalesce(try(each.value.digest_algorithm, null), "SHA256")
  authn_context_class_ref        = coalesce(
    try(each.value.authn_context_class_ref, null),
    "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport"
  )

  # Optional attributes: pass through if present
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
}
}

