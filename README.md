
# Okta Application Onboarding with Terraform

This project automates the onboarding of various application types into Okta using Terraform and a YAML input file.

## 📂 Project Structure

```
.
├── apps.yaml              # App definitions (OIDC, SAML, SWA, Bookmark)
├── main.tf                # Main Terraform logic and provisioning
├── variables.tf           # Variable declarations
├── terraform.tfvars       # Variable values
├── .terraform.lock.hcl    # Terraform provider lock file
├── success.log            # Logs success for each provisioned app
├── app_report.md          # Detailed Markdown report per app (generated post apply)
```

## 🚀 Features

- Supports four Okta app types:
  - OIDC (`okta_app_oauth`)
  - SAML (`okta_app_saml`)
  - SWA (`okta_app_swa`)
  - Bookmark (`okta_app_bookmark`)
- Reads app config from `apps.yaml`
- Dynamically handles optional fields
- Validates input and skips invalid entries
- Logs success to `success.log`
- Generates a Markdown report in `app_report.md`

## ✅ Usage

1. **Install Terraform** if not already:1
   https://www.terraform.io/downloads

2. **Initialize the project**:

```bash
terraform init
```

3. **Preview the plan**:

```bash
terraform plan
```

4. **Apply the configuration**:

```bash
terraform apply
```

5. **Review logs**:
   - `success.log` → status of each provisioned app
   - `app_report.md` → detailed fields per app

## 🛠 Customize

Update `apps.yaml` to add new apps or adjust configurations. Supported fields are documented per app type in the code.

## 📌 Notes

- `status` defaults to `ACTIVE` if not specified
- Missing required fields will automatically exclude that app from being provisioned

---

Built for scalable, declarative Okta onboarding.
