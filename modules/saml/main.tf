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

  subject_name_id_format = lookup(
    each.value,
    "subject_name_id_format",
    "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"
  )

  subject_name_id_template = coalesce(
    try(format("$${%s}", lookup(each.value, "subject_name_id_template", "user.email")), null),
    "$${user.email}"
  )


  user_name_template = try(
    replace(replace(lookup(each.value, "user_name_template", null), "{", ""), "}", ""),
    null
  )

 
  user_name_template_type = (
    try(
      replace(replace(lookup(each.value, "user_name_template", null), "{", ""), "}", ""),
      null
    ) != null
  ) ? "CUSTOM" : null

  user_name_template_push_status = lookup(each.value, "user_name_template_push_status", null)


  response_signed      = coalesce(try(each.value.response_signed, null), true)
  assertion_signed     = coalesce(try(each.value.assertion_signed, null), true)
  signature_algorithm  = coalesce(try(each.value.signature_algorithm, null), "RSA_SHA256")
  digest_algorithm     = coalesce(try(each.value.digest_algorithm, null), "SHA256")
  authn_context_class_ref = coalesce(
    try(each.value.authn_context_class_ref, null),
    "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport"
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
  }
}
