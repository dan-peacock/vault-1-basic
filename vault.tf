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

# Add to Terraform Variable Set
resource "tfe_organization" "tf_account" {
  name  = var.name
  email = var.email
}

resource "tfe_variable_set" "vault_details" {
  name         = "Vault Details"
  description  = "Variable set applied to all workspaces."
  global       = true
  organization = tfe_organization.tf_account.name
}

resource "tfe_variable" "vault_url" {
  key             = "vault_url"
  value           = hcp_vault_cluster.vault_cluster.vault_public_endpoint_url
  category        = "terraform"
  description     = "Public vault endpoint"
  variable_set_id = tfe_variable_set.vault_details.id
}

resource "tfe_variable" "vault_url" {
  key             = "vault_token"
  value           = hcp_vault_cluster_admin_token.vault_admin_token.token
  sensitive       = true
  category        = "terraform"
  description     = "Vault admin token"
  variable_set_id = tfe_variable_set.vault_details.id
}

