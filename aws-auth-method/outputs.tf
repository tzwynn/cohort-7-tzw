output "policy_role_name" {
  value = vault_aws_auth_backend_role.db_role.role_id
}

output "instance_profile_id" {
  value = aws_iam_instance_profile.vault-client.id 
}