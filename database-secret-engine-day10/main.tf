#Enable db secret engine
resource "vault_database_secrets_mount" "db" {
  path = "db"

  mysql {
    name           = "mysql"
    username       = "vault"
    password       = "vault"
    connection_url = "{{username}}:{{password}}@tcp(${data.terraform_remote_state.ec2-rds-day8.outputs.rds_hostname}:3306)"
    allowed_roles = ["*"]
  }

#Creating a role 
resource "vault_database_secret_backend_role" "readwrite_role" {
  name    = "readwrite-role"
  backend = vault_database_secrets_mount.db.path
  db_name = vault_database_secrets_mount.db.mysql[0].name
  default_ttl =600
  max_ttl =900
  creation_statements = [
    "CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';",
    "GRANT ALL PRIVILEGES ON projectdb.* TO '{{name}}'@'%';"
  ]
}

resource "vault_database_secret_backend_role" "readonly_role" {
   name    = "readonly-role"
  backend = vault_database_secrets_mount.db.path
  db_name = vault_database_secrets_mount.db.mysql[0].name
  default_ttl =600
  max_ttl =900
  creation_statements = [
    "CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';",
    "GRANT SELECT ON projectdb.* TO '{{name}}'@'%';"
  ]
}