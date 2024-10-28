#Enabling approle authmethod in vault
resource "vault_auth_backend" "approle_auth" {
  type = "approle"
}

#Creating policy for approle
resource "vault_policy" "aws_approle-policy" {
  name = "aws-approle-pol"

  policy = <<EOT
path "aws-master/*" {
  capabilities = ["read"]
}
path "db/* {
  capabilities = ["read"]
}
EOT
}

#Creating a role
resource "vault_approle_auth_backend_role" "aws_approle" {
  backend        = vault_auth_backend.approle_auth.path
  role_name      = "aws-approle"
  token_policies = [vault_policy.aws_approle-policy.name]
  token_ttl = 300
  token_max_ttl = 600
}

#Generating a secret id
resource "vault_approle_auth_backend_role_secret_id" "secret_id" {
  backend   = vault_auth_backend.approle_auth.path
  role_name = vault_approle_auth_backend_role.aws_approle.role_name
}