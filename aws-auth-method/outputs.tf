output "policy_role_name" {
  value = vault_aws_auth_backend_role.db_role.role_id
}