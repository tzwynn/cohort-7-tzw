#retriving data from terraform workspace vpc-day3
data "terraform_remote_state" "vpc-workspace" {
  backend = "remote"
  config = {
    organization = "cohort-7-tzw"
    workspaces = {
      name = "vpc-day3"
    }
  }
}

#retriving vpc_owner_id
data "aws_vpc" "selected" {
  id = data.terraform_remote_state.vpc-workspace.outputs.vpc_id #retirve vpc_id from peer_vpc_id data output
}

#retriving vpc_region
data "aws_arn" "vpc_region" {
  arn = data.aws_vpc.selected.arn
}

# for private subnet
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.terraform_remote_state.vpc-workspace.outputs.vpc_id]
  }

  tags = {
    Tier = "c7-private"
  }
}

data "aws_subnet" "private" {
  for_each = toset(data.aws_subnets.private.ids)
  id       = each.value
}

#to retrive hvn_link
data "hcp_hvn" "hvn" {
  hvn_id = var.hvn_id
}

#for db subnet
data "aws_subnets" "db" {
  filter {
    name   = "vpc-id"
    values = [data.terraform_remote_state.vpc-workspace.outputs.vpc_id]
  }

  tags = {
    Tier = "c7-db"
  }
}

data "aws_subnet" "db" {
  for_each = toset(data.aws_subnets.db.ids)
  id       = each.value
}

#creating a route table entry for private subnet
data "aws_route_table" "private_rt" {
  subnet_id = data.aws_subnets.private.ids[0]
}

#creating a route table entry for db subnet
data "aws_route_table" "db_rt" {
  subnet_id = data.aws_subnets.private.ids[0]
}