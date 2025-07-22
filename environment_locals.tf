locals {
  okta_api_token = getenv("OKTA_API_TOKEN")
  okta_org_name  = getenv("OKTA_ORG_NAME")
  okta_base_url  = getenv("OKTA_BASE_URL")
}
