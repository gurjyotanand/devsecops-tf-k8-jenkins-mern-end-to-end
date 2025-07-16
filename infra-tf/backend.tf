terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 5.95.0" 
    }
  }


backend "s3" {
    bucket         = "gurj-terraform-backend-bucket"
    region         = "us-east-1"
    key            = "devsecops-infra/terraform.tfstate"
    dynamodb_table = "gurj-terraform-state"
    encrypt        = true
  }

}

provider "aws" {
  region  = var.region
}