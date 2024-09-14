resource "hcp_hvn" "c7-hcp-hvn" {
  hvn_id         = "c7"
  cloud_provider = "aws"
  region         = "eu-west-2"
  cidr_block     = "172.25.16.0/20"
}

resource "hcp_vault_cluster" "c7-hcp-cluster" {
  cluster_id = "c7-cluster"
  hvn_id     = hcp_hvn.c7-hcp-hvn.hvn_id
  tier       = "starter_small"
  public_endpoint = true
}