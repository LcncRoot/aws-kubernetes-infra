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
  cidr_block = var.vpc_cidr
  
  enable_dns_support   = true  
  enable_dns_hostnames = true  

  tags = {
    Name = "aws-kubernetes-vpc" # Naming tag for resource organization
  }
}

########################################
# Internet Gateway for Public Subnets
########################################

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "eks-internet-gateway"
  }
}

########################################
# Public Route Table
########################################

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.public_route_table_cidr
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "eks-public-route-table"
  }
}

########################################
# Public Subnets (for EKS Worker Nodes)
########################################

resource "aws_subnet" "public" {
  count             = length(var.public_subnet_cidrs)
  vpc_id           = aws_vpc.main.id
  cidr_block       = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "aws-kubernetes-public-subnet-${count.index}"
  }
}

# Associate Public Subnets with Route Table
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

########################################
# Security Group for EKS
########################################

resource "aws_security_group" "eks_sg" {
  name        = var.security_group_name
  description = "Security group for EKS cluster"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "Allow worker nodes to connect to EKS API"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    security_groups  = [aws_eks_cluster.main.vpc_config[0].cluster_security_group_id]
  }

  ingress {
    description = "Allow all traffic within the cluster"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-cluster-sg"
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
# IAM Roles for Worker Nodes
########################################


resource "aws_iam_role" "eks_nodes" {
  name = "eks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

# Attach Required IAM Policies for Worker Nodes
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "ecr_readonly_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes.name
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

########################################
# Node group creation
########################################

resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "eks-node-group"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = aws_subnet.public[*].id

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 2
  }

  ami_type       = "AL2_x86_64"
  instance_types = ["t3.medium"]
  capacity_type  = "SPOT"

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ecr_readonly_policy
  ]
}
