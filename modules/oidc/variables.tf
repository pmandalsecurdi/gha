variable "apps" {
  description = "SAML applications to create"
  type = list(object({
    label                          = string
    acs_url                        = string
    audience                       = string
    status                         = optional(string)      # "ACTIVE" | "INACTIVE"

    subject_name_id_format         = optional(string)
    subject_name_id_template       = optional(string)      # e.g., "user.email" (your module can wrap to ${user.email})
    user_name_template             = optional(string)      # e.g., "user.email"
    user_name_template_push_status = optional(string)      # "DONT_PUSH" | "PUSH"

    response_signed                = optional(bool)
    assertion_signed               = optional(bool)
    signature_algorithm            = optional(string)      # e.g., "RSA_SHA256"
    digest_algorithm               = optional(string)      # e.g., "SHA256"
    authn_context_class_ref        = optional(string)

    attribute_statements = optional(list(object({
      name   = string
      values = list(string)
      type   = optional(string)                           # "EXPRESSION" | "GROUP" | "MAPPING"
    })))

    # Optional file-driven extras if your module supports them:
    x509_certificate_path          = optional(string)
    logo_path                      = optional(string)
  }))

  validation {
    condition = alltrue([
      for a in var.apps :
        length(trim(a.label)) > 0 &&
        can(regex("^https?://", a.acs_url))
    ])
    error_message = "Each SAML app must have a non-empty label and acs_url must start with http(s)://."
  }
}
