//--------------------------------------------------
//-Jump Server
//--------------------------------------------------
#Creating a security group jump server
resource "aws_security_group" "allow_ssh_jump" {
  name        = "allow-ssh-jump"
  description = "Allow ssh inbound traffic and all outbound traffic"
  vpc_id      = data.terraform_remote_state.vpc_workspace.outputs.vpc_id

  tags = {
    Name = "allow-ssh-jump"
  }
}

#Ingress rule
resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ingress_jump" {
  security_group_id = aws_security_group.allow_ssh_jump.id  
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

#Egress rule
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_egress_jump" {
  security_group_id = aws_security_group.allow_ssh_jump.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_instance" "jump" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  associate_public_ip_address = true
  key_name = "ssh-key-${random_pet.env.id}" #from keypair.tf
  subnet_id = data.aws_subnets.public.ids[0]
  vpc_security_group_ids = [aws_security_group.allow_ssh_jump.id]

  tags = {
    Name = "jump-server"
  }
  # Resources to ignore when changes make to code 
  lifecycle {
    ignore_changes = [
      ami,
      tags,
    ]
  }
}

//--------------------------------------------------
//-Application server with aws auth method
//--------------------------------------------------

#Creating a security group
resource "aws_security_group" "allow_ssh_app" {
  name        = "allow-ssh-app"
  description = "Allow ssh inbound traffic and all outbound traffic"
  vpc_id      = data.terraform_remote_state.vpc_workspace.outputs.vpc_id

  tags = {
    Name = "allow-ssh-app"
  }
}

#Ingress rule
resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ingress_app" {
  for_each = data.aws_subnet.public
  security_group_id = aws_security_group.allow_ssh_app.id  
  cidr_ipv4         = each.value.cidr_block # aws_instance.jump.private__ip >> can be used instaed of for_each
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

#Egress rule
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_egress_app" {
  security_group_id = aws_security_group.allow_ssh_app.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

#template file for ec2 user data
data "template_file" "vault_agent_aws" {
  template = file("${path.module}/template/ec2-aws-auth.tftpl")
  vars = {
    tpl_vault_server_addr = data.terraform_remote_state.hcp_vault.outputs.vault_private_endpoint_url
    MYSQL_HOST = aws_db_instance.project_rds.address
    MYSQL_USER = aws_db_instance.project_rds.username
    MYSQL_PASS = aws_db_instance.project_rds.password
  }
}

resource "aws_instance" "app_aws" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name = "ssh-key-${random_pet.env.id}" #from keypair.tf
  subnet_id = data.aws_subnets.private.ids[0]
  vpc_security_group_ids = [aws_security_group.allow_ssh_app.id]
  iam_instance_profile = data.terraform_remote_state.aws_auth_workspace.outputs.instance_profile_id
  user_data = template_file.vault_agent_aws.rendered

  tags = {
    Name = "app-server1"
  }
  lifecycle {
    ignore_changes = [
      ami,
      tags,
    ]
  }
}

//--------------------------------------------------
//-Application server with app-role auth method
//--------------------------------------------------

#template file for ec2 user data
data "template_file" "vault_agent_approle" {
  template = file("${path.module}/template/ec2-approle.tftpl")
  vars = {
    tpl_vault_server_addr = data.terraform_remote_state.hcp_vault.outputs.vault_private_endpoint_url
    login_role_id = data.terraform_remote_state.approle_auth_method.outputs.role_id
    login_secret_id = data.terraform_remote_state.approle_auth_method.outputs.secret_id
  }
}

resource "aws_instance" "app_approle" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name = "ssh-key-${random_pet.env.id}" #from keypair.tf
  subnet_id = data.aws_subnets.private.ids[1]
  vpc_security_group_ids = [aws_security_group.allow_ssh_app.id]
  user_data = template_file.vault_approle_aws.rendered

  tags = {
    Name = "app-server2"
  }
  lifecycle {
    ignore_changes = [
      ami,
      tags,
    ]
  }
}
