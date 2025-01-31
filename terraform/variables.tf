variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
  default     = "aws-kubernetes-cluster"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_route_table_cidr" {
  description = "CIDR block for public route table to allow outbound internet access"
  type        = string
  default     = "0.0.0.0/0"
}

variable "security_group_name" {
  description = "Name for the security group assigned to EKS"
  type        = string
  default     = "eks-cluster-sg"
}

variable "eks_ssh_key" {
  description = "EC2 Key Pair name for SSH access to worker nodes"
  type        = string
  default     = "my-key-pair" # Change this to an actual AWS key pair
}

variable "availability_zones" {
  description = "Availability Zones for subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}
