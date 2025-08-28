variable "apps" {
  description = "OIDC (OAuth 2.0 / OIDC) applications to create"
  type = list(object({
    label                      = string
    type                       = optional(string)          # "web", "native", "service"
    redirect_uris              = optional(list(string))
    post_logout_redirect_uris  = optional(list(string))
    grant_types                = optional(list(string))    # e.g. ["authorization_code","refresh_token"]
    response_types             = optional(list(string))    # e.g. ["code"]
    token_endpoint_auth_method = optional(string)          # e.g. "client_secret_post","none"
    initiate_login_uri         = optional(string)
    status                     = optional(string)          # "ACTIVE" | "INACTIVE"

    # Common extras you may wire in your module (all optional):
    consent_method             = optional(string)
    login_mode                 = optional(string)
    issuer_mode                = optional(string)
    pkce_required              = optional(bool)
    auto_key_rotation          = optional(bool)
    refresh_token_leeway       = optional(number)
    idp_initiated_login        = optional(bool)
  }))

  validation {
    condition = alltrue([
      for a in var.apps :
        length(trim(a.label)) > 0
    ])
    error_message = "Each OIDC app must have a non-empty label."
  }
}
