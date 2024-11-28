# IAM Role for EKS
resource "aws_iam_role" "eks_cluster_role" {
  name = "cluster-eks-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "cluster-eks-role"
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}


# Create a VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.7.0"

  name = "venkat-eks-vpc"
  cidr = var.vpc_cidr

  azs             = data.aws_availability_zones.available.names
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }
}


# Create the EKS Cluster

locals {
  cluster_name = "venkat-eks-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.8.4"
  cluster_name    = local.cluster_name
  cluster_version = var.kubernetes_version
  subnet_ids      = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  cluster_endpoint_public_access = true
  cluster_endpoint_private_access = false

  # IAM Roles

  eks_managed_node_groups = [
    {
      name              = "worker-group-1"
      instance_types    = ["t3.medium"]
      min_size          = 1
      max_size          = 3
      desired_size      = 2
      subnets           = module.vpc.private_subnets
      launch_template_name   = "eks-demo-cluster"
      launch_template_use_name_prefix = false
    }
  ]

  tags = {
    cluster = "demo"
  }
}

