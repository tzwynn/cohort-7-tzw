data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

#retriving data from terraform workspace vpc-day3
data "terraform_remote_state" "vpc_workspace" {
  backend = "remote"
  config = {
    organization = "cohort-7-tzw"
    workspaces = {
      name = "vpc-day3"
    }
  }
}

#retriving data from terraform workspace aws-auth-method-day6
data "terraform_remote_state" "aws_auth_workspace" {
  backend = "remote"
  config = {
    organization = "cohort-7-tzw"
    workspaces = {
      name = "aws-auth-method-day6"
    }
  }
}

#retriving data from terraform workspace chort-7-tzw
data "terraform_remote_state" "hcp_vault" {
  backend = "remote"
  config = {
    organization = "cohort-7-tzw"
    workspaces = {
      name = "cohort-7-tzw"
    }
  }
}

#retriving data from terraform workspace approle-auth-method-day7
data "terraform_remote_state" "approle_auth_method" {
  backend = "remote"
  config = {
    organization = "cohort-7-tzw"
    workspaces = {
      name = "approle-auth-method-day7"
    }
  }
}


#retriving vpc_owner_id
data "aws_vpc" "selected" {
  id = data.terraform_remote_state.vpc_workspace.outputs.vpc_id #retirve vpc_id from peer_vpc_id data output
}

#public subnet for jump server
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.terraform_remote_state.vpc_workspace.outputs.vpc_id]
  }

  tags = {
    Name = "c7-public*"
  }
}

data "aws_subnet" "public" {
  for_each = toset(data.aws_subnets.public.ids)
  id       = each.value
}

#private subnet for app server
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.terraform_remote_state.vpc_workspace.outputs.vpc_id]
  }

  tags = {
    Name = "c7-private*"
  }
}

data "aws_subnet" "private" {
  for_each = toset(data.aws_subnets.private.ids)
  id       = each.value
}

