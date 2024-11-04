//-------------------------------------------------------------------------------------
// Create SSH Key-pair for EC2 Instance
//-------------------------------------------------------------------------------------
resource "tls_private_key" "main" {
  algorithm = "RSA"
}
# resource "null_resource" "main" {
#   provisioner "local-exec" {
#     command = "echo \"${tls_private_key.main.private_key_pem}\" > private.key"
#   }
#   provisioner "local-exec" {
#     command = "chmod 600 private.key"
#   }
# }
resource "random_pet" "env" {
  length    = 2
  separator = "_"
}
resource "aws_key_pair" "main" {
  key_name   = "ssh-key-${random_pet.env.id}"
  public_key = tls_private_key.main.public_key_openssh
}