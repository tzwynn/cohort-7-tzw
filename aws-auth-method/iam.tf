#creating an IAM user
resource "aws_iam_user" "aws_auth_user" {
  name = "vault-auth-admin"
  path = "/"
}

#creating an access key for the IAM user
resource "aws_iam_access_key" "aws_auth_user_key" {
  user = aws_iam_user.aws_auth_user.name
}

#creating policy document
data "aws_iam_policy_document" "aws_auth_user_policy" {
 statement {
    sid    = "VaultAWSAuthMethod"
    effect = "Allow"
    actions = [
        "ec2:DescribeInstances",
        "iam:GetInstanceProfile",
        "iam:GetUser",
        "iam:ListRoles",
        "iam:GetRole"
     ]
    resources = ["*"]
  }
}

#attaching policy document to the user
resource "aws_iam_user_policy" "aws_auth_user_policy_att" {
  name   = "ec2-user-policy"
  user   = aws_iam_user.aws_auth_user.name
  policy = data.aws_iam_policy_document.aws_auth_user_policy.json
}

#Assume Role

#creating assume role policy
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

#creating IAM role
resource "aws_iam_role" "ec2_role" {
  name = "aws-auth-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}