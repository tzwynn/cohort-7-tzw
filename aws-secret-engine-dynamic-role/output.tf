output "access-kye" {
  value     = data.vault_aws_access_credentials.creds.access_key
  sensitive = true
}

output "secret_key" {
  value     = data.vault_aws_access_credentials.creds.secret_key
  sensitive = true

}