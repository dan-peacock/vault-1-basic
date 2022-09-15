# Create Vault Cluster
provider "hcp" {
  client_id     = var.hcp_client_id
  client_secret = var.hcp_secret_id
}

resource "hcp_vault_cluster" "vault_cluster" {
  hvn_id     = var.hcp_net_id
  cluster_id = "demo-cluster"
  public_endpoint = true
  tier = "starter_small"
}

resource "hcp_vault_cluster_admin_token" "vault_admin_token" {
  cluster_id = hcp_vault_cluster.vault_cluster.cluster_id
}

# Configure Secret Engines
provider "vault" {
  address = hcp_vault_cluster.vault_cluster.vault_public_endpoint_url
  token = hcp_vault_cluster_admin_token.vault_admin_token.token
}

module "vault_aws_secret_backend" {
  source = "./modules/aws"
  count = var.aws_enabled ? 1 : 0

  aws_access_key = var.aws_access_key
  aws_secret_key = var.aws_secret_key
}

module "vault_azure_secret_backend" {
  source = "./modules/azure"
  count = var.azure_enabled ? 1 : 0

  subscription_ID = var.subscription_ID
  tenant_ID = var.tenant_ID
  SP_Password = var.SP_Password
  SP_AppID = var.SP_AppID
}

# Configure Login
resource "vault_auth_backend" "userpass" {
  type = "userpass"
}

# Generate password 
resource "vault_generic_secret" "random" {
  path = "sys/tools/random"

  data_json = <<EOT
{
  "format": "hex"
}
EOT
}

# Create a user
resource "vault_generic_endpoint" "user" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/userpass/users/${var.username}"
  ignore_absent_fields = true

  data_json = <<EOT
{
  "policies": ["admins", "eaas-client"],
  "password": ${resource.vault_generic_secret.random.data}"
}
EOT
}

# Add Vault Info to Terraform Variable Set
provider "tfe" {
  token = var.tfc_token
}

resource "tfe_variable_set" "vault_details" {
  name         = "Vault Details"
  description  = "Variable set applied to all workspaces."
  global       = true
  organization = var.tfc_org_name
}

resource "tfe_variable" "vault_url" {
  depends_on = [hcp_vault_cluster.vault_cluster]

  key             = "vault_url"
  value           = hcp_vault_cluster.vault_cluster.vault_public_endpoint_url
  category        = "terraform"
  description     = "Public vault endpoint"
  variable_set_id = tfe_variable_set.vault_details.id
}

resource "tfe_variable" "vault_password" {

  key             = "vault_password"
  value           = vault_generic_secret.random.data_json
  sensitive       = true
  category        = "terraform"
  description     = "Vault password"
  variable_set_id = tfe_variable_set.vault_details.id
}

resource "tfe_variable" "vault_username" {

  key             = "vault_username"
  value           = var.username
  sensitive       = true
  category        = "terraform"
  description     = "Vault username"
  variable_set_id = tfe_variable_set.vault_details.id
}