variable "okta_api_token" {
  type        = string
  description = "Okta API Token"
  default     = null
}

variable "okta_org_name" {
  type        = string
  description = "Okta Org Name"
  default     = null
}

variable "okta_base_url" {
  type        = string
  description = "Okta Base URL (e.g., okta.com)"
  default     = null
}
