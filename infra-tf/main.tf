# Creates VPC Network
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"

  name = "end-to-end-devsecops-vpc"
  cidr = "10.1.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.1.1.0/24", "10.1.2.0/24"]
  public_subnets  = ["10.1.101.0/24", "10.1.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_dns_hostnames   = true

  # Auto-cleanup dependencies before destroy
  create_database_subnet_group           = false  # Disable if not used
  create_elasticache_subnet_group        = false  # Disable if not used
  create_redshift_subnet_group           = false  # Disable if not used
  enable_flow_log                        = false  # Disable to avoid log retention blocks

  # Force destroy settings for subnets
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
  
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name    = "end-to-end-devsecops"
  cluster_version = "1.31"

  # Optional
  cluster_endpoint_public_access = true

  # Adds the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Creates worker nodes
  eks_managed_node_groups = {
    default = {
      min_size     = 1
      max_size     = 3
      desired_size = 2
      instance_types = ["t3.medium"]
    }
  }
  depends_on = [module.vpc]
}

resource "aws_ecr_repository" "frontend" {
  name = "frontend" # Replace with your desired repository name

  image_tag_mutability = "IMMUTABLE" # Optional: Controls the tag mutability, choose between "MUTABLE" or "IMMUTABLE"
  force_delete = true
  
  encryption_configuration {
    encryption_type = "AES256" # Optional: Can be "AES256" or "KMS" for more advanced encryption
  }

  lifecycle {
    prevent_destroy = false # Optional: Prevents accidental deletion of the repository
  }
}

resource "aws_ecr_repository" "backend" {
  name = "backend" # Replace with your desired repository name

  image_tag_mutability = "IMMUTABLE" # Optional: Controls the tag mutability, choose between "MUTABLE" or "IMMUTABLE"
  force_delete = true
  encryption_configuration {
    encryption_type = "AES256" # Optional: Can be "AES256" or "KMS" for more advanced encryption
  }

  lifecycle {
    prevent_destroy = false # Optional: Prevents accidental deletion of the repository
  }
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "frontend_repository_url" {
  value = aws_ecr_repository.frontend.repository_url
}

output "backend_repository_url" {
  value = aws_ecr_repository.backend.repository_url
}
