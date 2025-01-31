########################################
# AWS EKS Cluster
########################################

resource "aws_eks_cluster" "main" {
  name     = "aws-kubernetes-cluster"
  role_arn = aws_iam_role.eks.arn

  vpc_config {
    subnet_ids = aws_subnet.public[*].id
  }

  # Ensures that the IAM role and policies are created before EKS
  depends_on = [ 
    aws_iam_role_policy_attachment.eks_cluster,
    aws_iam_role_policy_attachment.eks_service
  ]
}
########################################
# VPC settings
########################################
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  
  enable_dns_support   = true  
  enable_dns_hostnames = true  

  tags = {
    Name = "aws-kubernetes-vpc" # Naming tag for resource organization
  }
}

########################################
# Public Subnets (for EKS Worker Nodes)
########################################

resource "aws_subnet" "public" {
  count = 2  
  vpc_id = aws_vpc.main.id
  cidr_block = element(["10.0.1.0/24", "10.0.2.0/24"], count.index)
  # Ensures each subnet is placed in a separate availability zone for HA
  availability_zone = element(["us-east-1a", "us-east-1b"], count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "aws-kubernetes-public-subnet-${count.index}"
  }
}
########################################
# IAM Roles for EKS Cluster
########################################

resource "aws_iam_role" "eks" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

########################################
# IAM Policies for EKS Role
########################################

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks.name
}

resource "aws_iam_role_policy_attachment" "eks_service" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks.name
}