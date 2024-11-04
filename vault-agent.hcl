#exit_after_auth = true
#To run as a process in Linux
pid_file = "/home/tzw/cohort-7-tzw/pidfile"
auto_auth {
   method "approle" { #this can be other auth method in vault like aws auth method
       mount_path = "auth/approle" #enable approle default mount path
       namespace = "admin"
       config = {
           role_id_file_path = "/home/tzw/cohort-7-tzw/role_id" 
           secret_id_file_path = "/home/tzw/cohort-7-tzw/secret_id"
           remove_secret_id_file_after_reading = false
       }
   }
   #for vault token after login
   sink "file" {
       config = {
           path = "/home/tzw/cohort-7-tzw/vault_token"
       }
   }
}
vault {
   address = "https://c7-cluster-public-vault-be49a28f.17f7b53c.z1.hashicorp.cloud:8200"
}
template_config {
  exit_on_retry_failure = true
  max_connections_per_host = 20 #maximum concurrent clients
  lease_renewal_threshold = 0.90 #to read secret again in 90% of lease duration reached
}
template {
  source = "/home/tzw/cohort-7-tzw/aws-tmpl.tmpl"
  destination  = "/tmp/agent/render-content.txt"
}
