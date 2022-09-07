# # Read Credentials from Vault
# data "vault_aws_access_credentials" "creds" {
#   backend = data.terraform_remote_state.creds.outputs.backend
#   role    = data.terraform_remote_state.creds.outputs.role
# }

# # Provision EC2 instance to AWS
# provider "aws" {
#   region     = "eu-west-2"
#   access_key = data.vault_aws_access_credentials.creds.access_key
#   secret_key = data.vault_aws_access_credentials.creds.secret_key
# }

# resource "aws_instance" "main" {
#   ami           = ""
#   instance_type = "t2.nano"
# }
