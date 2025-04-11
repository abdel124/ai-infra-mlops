################################
# GitHub OIDC Identity Provider
################################
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "74f3a68f16524f15424927704c9506f55a9316bd"
  ]
}

##############################
# IAM Role for GitHub Actions
#############################
resource "aws_iam_role" "github_actions_deploy" {
  name = "GitHubActionsDeployRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringLike = {
          # 🔥 TEMP: Wildcard allows all refs from your repo (good for debugging)
          # Later, change this to: "repo:<user>/<repo>:ref:refs/heads/main"
          "token.actions.githubusercontent.com:sub" = "repo:abdel124/ai-infra-mlops:*"
        }
      }
    }]
  })
}

#############################
# Attach Permissions: ECR + EKS
#############################

resource "aws_iam_role_policy_attachment" "ecr_access" {
  role       = aws_iam_role.github_actions_deploy.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_role_policy_attachment" "eks_access" {
  role       = aws_iam_role.github_actions_deploy.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

#############################
# Output the role ARN for GitHub
#############################

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions_deploy.arn
}