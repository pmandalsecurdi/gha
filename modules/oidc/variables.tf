variable "apps" {
  description = "OIDC apps"
  type = list(object({
    label                      = string
    # let 'type' be optional, default to web
    type                       = optional(string, "web")

    # for non-service apps we need redirect_uris; keep type consistent across all items
    redirect_uris              = optional(list(string), [])
    post_logout_redirect_uris  = optional(list(string))   # may be omitted

    grant_types                = optional(list(string))   # may be omitted; defaults handled in resource
    response_types             = optional(list(string))   # may be omitted; defaults handled in resource
    token_endpoint_auth_method = optional(string)         # may be omitted; default handled in resource

    login_uri                  = optional(string)
    user_name_template         = optional(string)
  }))

  # Guardrails so data stays valid without breaking types
  validation {
    condition = alltrue([
      for a in var.apps :
      contains(["web","service","native","browser"], a.type)
    ])
    error_message = "Each OIDC app 'type' must be one of: web, service, native, browser."
  }

  validation {
    condition = alltrue([
      for a in var.apps :
      (a.type == "service" && length(a.redirect_uris) == 0) ||
      (a.type != "service" && length(a.redirect_uris) > 0)
    ])
    error_message = "Non-service apps must have at least one redirect_uri; service apps must have none."
  }
}
