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
provider "tfe" {
  token = var.token
}

data tfe_organization "tfe_org" {}

resource "tfe_variable_set" "vault_details" {
  name         = "Vault Details"
  description  = "Variable set applied to all workspaces."
  global       = true
  organization = data.tfe_organization.tfe_org.id
}

resource "tfe_variable" "vault_url" {
  depends_on = [hcp_vault_cluster.vault_cluster.vault_cluster]

  key             = "vault_url"
  value           = hcp_vault_cluster.vault_cluster.vault_public_endpoint_url
  category        = "terraform"
  description     = "Public vault endpoint"
  variable_set_id = tfe_variable_set.vault_details.id
}

resource "tfe_variable" "vault_token" {
  depends_on = [hcp_vault_cluster_admin_token.vault_admin_token]

  key             = "vault_token"
  value           = hcp_vault_cluster_admin_token.vault_admin_token.token
  sensitive       = true
  category        = "terraform"
  description     = "Vault admin token"
  variable_set_id = tfe_variable_set.vault_details.id
}

