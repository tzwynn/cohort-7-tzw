output "role_name" {
    value = vault_jwt_auth_backend_role.c7-jwt-admin-role.role_name
  
}

output "openid_claims" {
    value = vault_jwt_auth_backend.c7-jwt-vault.bound_claims
  
}