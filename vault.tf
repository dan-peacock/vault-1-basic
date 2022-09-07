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

# Configure Secrets Engine


# Configure Policy


#Outputs
output "vault_token" {
    sensitive = true
    value = hcp_vault_cluster_admin_token.vault_admin_token.token
}

output "vault_url" {
    value = hcp_vault_cluster.vault_cluster.vault_public_endpoint_url
}