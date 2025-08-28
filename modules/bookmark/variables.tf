variable "apps" {
  description = "Bookmark applications to create"
  type = list(object({
    label     = string
    url       = string
    status    = optional(string)      # "ACTIVE" | "INACTIVE"

    # Optional extras if your module wires them
    logo_path = optional(string)
    notes     = optional(string)
  }))

  validation {
    condition = alltrue([
      for a in var.apps :
        length(trim(a.label)) > 0 &&
        can(regex("^https?://", a.url))
    ])
    error_message = "Each Bookmark app must have a non-empty label and url must start with http(s)://."
  }
}
