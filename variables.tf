variable "aws_region" {
  default = "us-east-1"
  type = string
  description = "AWS Regions for EKS Cluster"
}

variable "kubernetes_version" {
    description = "kubernetes version"
    default = 1.27
}

variable "vpc_cidr" {
  description = "vpc cidr ranges"
  default = "10.0.0.0/16"
}