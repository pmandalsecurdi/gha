locals {
  raw = yamldecode(file("${path.root}/apps.yaml"))

  # ---------- OIDC ----------
  _oidc_defaults = {
    type                       = "web"
    redirect_uris              = []
    post_logout_redirect_uris  = []
    grant_types                = []
    response_types             = []
    token_endpoint_auth_method = null
    login_uri                  = null
    user_name_template         = ""
  }

  apps_oidc = [
    for app in try(local.raw.oidc, []) : merge(
      local._oidc_defaults,
      app,
      {
        label                      = app.label
        type                       = try(app.type, "web")
        redirect_uris              = try(app.redirect_uris, [])
        post_logout_redirect_uris  = try(app.post_logout_redirect_uris, [])
        grant_types                = try(app.grant_types, [])
        response_types             = try(app.response_types, [])
        login_uri                  = try(app.login_uri, null)
        user_name_template         = try(app.user_name_template, "")
        token_endpoint_auth_method = try(app.token_endpoint_auth_method, null)
      }
    )
  ]

  # ---------- SAML ----------
  _saml_defaults = {
    subject_name_id_format         = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"
    subject_name_id_template       = "{user.email}"
    user_name_template             = "{user.email}"
    user_name_template_push_status = null
    response_signed                = true
    assertion_signed               = true
    signature_algorithm            = "RSA_SHA256"
    digest_algorithm               = "SHA256"
    authn_context_class_ref        = "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport"
    x509_certificate_path          = null
    attribute_statements           = []
  }

  apps_saml = [
    for app in try(local.raw.saml, []) : merge(
      local._saml_defaults,
      app,
      {
        label                    = app.label
        acs_url                  = app.acs_url
        audience                 = app.audience
        subject_name_id_format   = try(app.subject_name_id_format, local._saml_defaults.subject_name_id_format)
        subject_name_id_template = try(app.subject_name_id_template, local._saml_defaults.subject_name_id_template)
        user_name_template       = try(app.user_name_template, local._saml_defaults.user_name_template)
        attribute_statements     = try(app.attribute_statements, [])
      }
    )
  ]

  # ---------- SWA ----------
  _swa_defaults = {
    username_field = "txtbox-username"
    password_field = "txtbox-password"
    button_field   = "btn-login"
    logo_path      = "assets/bookmark-logo.png"
  }

  apps_swa = [
    for app in try(local.raw.swa, []) : merge(
      local._swa_defaults,
      app,
      {
        label     = app.label
        url       = app.url
        logo_path = try(app.logo_path, local._swa_defaults.logo_path)
      }
    )
  ]

  # ---------- Bookmark ----------
  _bookmark_defaults = {
    logo_path = "assets/bookmark-logo.png"
  }

  apps_bookmark = [
    for app in try(local.raw.bookmark, []) : merge(
      local._bookmark_defaults,
      app,
      {
        label     = app.label
        url       = app.url
        logo_path = try(app.logo_path, local._bookmark_defaults.logo_path)
      }
    )
  ]
}
