#Creating IAM user
resource "aws_iam_user" "vault-admin-user" {
  name = var.iam-user-name
  path = "/"

  tags = {
    Name = "vault-admin-user"
  }
}

#Creating an access key for IAM user
resource "aws_iam_access_key" "vault-admin-key" {
  user = aws_iam_user.vault-admin-user.name
}

#Creating a policy
data "aws_iam_policy_document" "vault-admin-policy-doc" {
  statement {
    effect    = "Allow"
    actions   = [
        "iam:AttachUserPolicy",
        "iam:CreateUser",
        "iam:CreateAccessKey",
        "iam:DeleteUser",
        "iam:DeleteAccessKey",
        "iam:DeleteUserPolicy",
        "iam:DetachUserPolicy",
        "iam:GetUser",
        "iam:ListAccessKeys",
        "iam:ListAttachedUserPolicies",
        "iam:ListGroupsForUser",
        "iam:ListUserPolicies",
        "iam:PutUserPolicy",
        "iam:AddUserToGroup",
        "iam:RemoveUserFromGroup"
        ]
    resources = [
    "arn:aws:iam::058264393890:user/vault-*"
        ]
  }
}

#Binding the policy to the user
resource "aws_iam_user_policy" "vault-admin-policy-att" {
  name   = "vault-admin-policy"
  user   = aws_iam_user.vault-admin-user.name
  policy = data.aws_iam_policy_document.vault-admin-policy-doc.json
}