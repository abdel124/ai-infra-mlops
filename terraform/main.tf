provider "aws" {
  region = "us-west-2"
}

#####################
# VPC Module
#####################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.0"

  name = "mlops-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}

######################
# EKS Module 
######################
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "18.20.0"
  cluster_name    = "mlops-cluster"
  cluster_version = "1.28"

  subnet_ids = module.vpc.private_subnets
  vpc_id     = module.vpc.vpc_id

  enable_irsa = true  # This enables IAM Roles for Service Accounts
  
  manage_aws_auth_configmap = true

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::349865279621:user/serverless"
      username = "serverless"
      groups   = ["system:masters"]
    }
  ]

  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::349865279621:role/GitHubActionsDeployRole"
      username = "github-actions"
      groups   = ["system:masters"]
    }
  ]

  eks_managed_node_groups = {
    mlops_nodes = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1

      instance_types = ["t3.medium"]
    }
  }
}