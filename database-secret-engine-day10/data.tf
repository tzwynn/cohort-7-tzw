#retriving data from terraform workspace ec2-rds-day8
data "terraform_remote_state" "ec2-rds-day8" {
  backend = "remote"
  config = {
    organization = "cohort-7-tzw"
    workspaces = {
      name = "ec2-rds-day8"
    }
  }
}