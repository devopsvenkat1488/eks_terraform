output "vpc_id" {
  value = module.vpc.vpc_id
}

output "subnets" {
  value = module.vpc.private_subnets
}

output "eks_cluster_name" {
  value = module.eks.cluster_id
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

# Output the Cluster Endpoint and IAM Role
output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_arn" {
  value = module.eks.cluster_arn
}

output "cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}

output "eks_cluster_role_arn" {
  value = aws_iam_role.eks_cluster_role.arn
}
