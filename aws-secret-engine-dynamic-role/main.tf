#Enabling secret engine in vault and configuering root
resource "vault_aws_secret_backend" "aws" {
  access_key = aws_iam_access_key.vault-admin-key.id
  secret_key = aws_iam_access_key.vault-admin-key.secret
  region = "eu-west-2"
  path = "aws-master"
  default_lease_ttl_seconds = 900
  max_lease_ttl_seconds = 1500
}

#Creating dynamic admin role
resource "vault_aws_secret_backend_role" "admin-access-role" {
  backend = vault_aws_secret_backend.aws.path
  name    = "admin-access-role"
  credential_type = "iam_user"
  policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]

}

resource "time_sleep" "wait_before_fetching_creds" {
  depends_on      = [vault_aws_secret_backend_role.admin-access-role]
  create_duration = "10s"
}

#Retriving the role data
data "vault_aws_access_credentials" "creds" {
  backend = vault_aws_secret_backend.aws.path
  role    = vault_aws_secret_backend_role.admin-access-role.name
}
