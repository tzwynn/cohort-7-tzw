#enabling a new auth method in vault
resource "vault_auth_backend" "aws_auth" {
  type = "aws"
}

#Configuring the client used by an AWS Auth Backend in Vault
resource "vault_aws_auth_backend_client" "aws_auth_engine" {
  backend    = vault_auth_backend.aws_auth.path
  access_key = aws_iam_access_key.aws_auth_user_key.id
  secret_key = aws_iam_access_key.aws_auth_user_key.secret
}

#Creating a db-policy for the role
resource "vault_policy" "db_policy" {
  name = "db-policy"
  policy = <<EOT
# Allow tokens to query themselves
path "auth/token/lookup-self" {
  capabilities = ["read"]
}
# Allow tokens to renew themselves
path "auth/token/renew-self" {
    capabilities = ["update"]
}
# Allow tokens to revoke themselves
path "auth/token/revoke-self" {
    capabilities = ["update"]
}
path "db/" {
  capabilities = ["read","list"]
}
path "db/*" {
  capabilities = ["read","list"]
}
path "aws-master/" {
  capabilities = ["read","list"]
}
path "aws-master/*" {
  capabilities = ["read","list"]
}
EOT
}

resource "time_sleep" "wait_before_creating_role" {
  depends_on      = [aws_iam_role.ec2_role]
  create_duration = "20s"
}

#Creating a role
resource "vault_aws_auth_backend_role" "db_role" {
  backend                         = vault_auth_backend.aws_auth.path
  role                            = "db-role"
  auth_type                       = "iam"
  bound_iam_principal_arns        = [aws_iam_role.ec2_role.arn]
  token_ttl                       = 300 #ttl for the token from the vault side
  token_max_ttl                   = 600
  token_policies                  = [vault_policy.db_policy.name]
}