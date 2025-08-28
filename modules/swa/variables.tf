variable "apps" {
  description = "SWA (Secure Web Auth) applications to create"
  type = list(object({
    label          = string
    url            = string                               # sign-in page URL
    status         = optional(string)                      # "ACTIVE" | "INACTIVE"

    # Page element selectors/ids (module maps these to resource fields)
    username_field = optional(string)
    password_field = optional(string)
    button_field   = optional(string)

    # Optional behaviors/fields (expose only those your module uses)
    auto_submit         = optional(bool)
    hide_password_field = optional(bool)
    redirect_url        = optional(string)

    # Optional logo file if your module supports uploading it
    logo_path       = optional(string)
  }))

  validation {
    condition = alltrue([
      for a in var.apps :
        length(trim(a.label)) > 0 &&
        can(regex("^https?://", a.url))
    ])
    error_message = "Each SWA app must have a non-empty label and url must start with http(s)://."
  }
}
