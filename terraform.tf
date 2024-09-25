terraform {
  required_version = "~>1.9.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.68.0"
    }
  }
  backend "s3" {
    bucket         = "eks-terraform-state-s3"
    dynamodb_table = "tfstate-locking"
    region         = "ap-south-1"
#   profile        = "tfstate-user" Since we are executing from an EC2 Instance we have created a IAM role and assigned the same to the EC2 Instance.
# so not using the profile parameter.
  }
}