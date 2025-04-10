output "cluster_name" {
  value = module.eks.cluster_name
}

output "subnet_ids" {
  ##
  value = module.vpc.private_subnets
}

output "vpc_id" {
  value = module.vpc.vpc_id
}