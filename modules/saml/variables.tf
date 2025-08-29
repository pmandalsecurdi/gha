variable "apps" {
  description = "SAML apps"
  type = list(object({
    # required
    label                  = string
    acs_url                = string
    audience               = string

    # optional with sensible defaults
    subject_name_id_format         = optional(string, "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress")
    subject_name_id_template       = optional(string, "{user.email}")
    user_name_template             = optional(string, "{user.email}")
    user_name_template_push_status = optional(string)

    response_signed        = optional(bool, true)
    assertion_signed       = optional(bool, true)
    signature_algorithm    = optional(string, "RSA_SHA256")
    digest_algorithm       = optional(string, "SHA256")
    authn_context_class_ref= optional(string, "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport")
    x509_certificate_path  = optional(string)

    attribute_statements = optional(list(object({
      name   = string
      values = list(string)
    })), [])
  }))

  # guardrails
  validation {
    condition     = alltrue([for a in var.apps : can(a.acs_url) && can(a.audience)])
    error_message = "Each SAML app must include 'acs_url' and 'audience'."
  }
}
