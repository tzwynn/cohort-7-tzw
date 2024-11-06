output "rds_hostname"{
    description = "RDS instance hostname"
    value = aws_db_instance.project_rds.address
}

output "rds_port"{
    description = "RDS instance port"
    value = aws_db_instance.project_rds.port
}

output "rds_username"{
    description = "RDS instance root username"
    value = aws_db_instance.project_rds.username
}

output "endpoints" {
  value = <<EOF
AWS RDS Endpoint:  ${aws_db_instance.project_rds.endpoint}
For example:
    mysql -h ${aws_db_instance.project_rds.address} -P ${aws_db_instance.project_rds.port} -u ${aws_db_instance.project_rds.username} -p
Jump Server IP (public):  ${aws_instance.jump.public_ip}
Jump Server IP (private): ${aws_instance.jump.private_ip}
For example:
   ssh -i private.key ubuntu@${aws_instance.jump.public_ip}
APP Client IP (private): ${aws_instance.app_aws.private_ip}
For example:
   ssh -i private.key ubuntu@${aws_instance.app_aws.private_ip}
APP Approle Client IP (private): ${aws_instance.app_approle.private_ip}
For example:
   ssh -i private.key ubuntu@${aws_instance.app_approle.private_ip}
EOF
}
output "private_key" {
  value = nonsensitive(tls_private_key.main.private_key_pem)
}