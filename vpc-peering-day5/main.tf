resource "hcp_aws_network_peering" "hvn-to-vpc" {
  hvn_id          = var.hvn_id
  peering_id      = "hvn-to-vpc"
  peer_vpc_id     = data.terraform_remote_state.vpc-workspace.outputs.vpc_id #vpc_id is output name of the vpc created
  peer_account_id = data.aws_vpc.selected.owner_id
  peer_vpc_region = data.aws_arn.vpc_region.region
}

resource "aws_vpc_peering_connection_accepter" "peer" {
  vpc_peering_connection_id = hcp_aws_network_peering.hvn-to-vpc.provider_peering_id
  auto_accept               = true
}

resource "hcp_hvn_route" "hvn-to-private" {
  for_each         = data.aws_subnet.private
  hvn_link         = data.hcp_hvn.hvn.self_link
  hvn_route_id     = each.value.id
  destination_cidr = each.value.cidr_block
  target_link      = hcp_aws_network_peering.hvn-to-vpc.self_link
}

resource "hcp_hvn_route" "hvn-to-db" {
  for_each         = data.aws_subnet.db
  hvn_link         = data.hcp_hvn.hvn.self_link
  hvn_route_id     = each.value.id
  destination_cidr = each.value.cidr_block
  target_link      = hcp_aws_network_peering.hvn-to-vpc.self_link
}

resource "aws_route" "private-rt" {
  route_table_id            = data.aws_route_table.private_rt.id
  destination_cidr_block    = data.hcp_hvn.hvn.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.id
}

resource "aws_route" "db-rt" {
  route_table_id            = data.aws_route_table.db_rt.id
  destination_cidr_block    = data.hcp_hvn.hvn.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.id
}