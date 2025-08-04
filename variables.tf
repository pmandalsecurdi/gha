variable "okta_org_name" {
  type        = string
  description = "Okta organization name"
}

variable "okta_base_url" {
  type        = string
  description = "Okta base URL"
}

variable "okta_api_token" {
  type        = string
  description = "Okta API token"
  sensitive   = true
}
