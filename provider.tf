provider "aws" {
  region  = "ap-south-1"
 # profile = "terraform"  Since we are executing from an EC2 Instance we have created a IAM role and assigned the same to the EC2 Instance.
 # so not using the profile parameter.
}