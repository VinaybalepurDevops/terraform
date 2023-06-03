#Creation of VPC
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.name
  cidr = var.cidr

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = [var.private-subnet1, var.private-subnet2]
  public_subnets  = [var.public-subnet1, var.public-subnet2]

  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Terraform = "true"
    Environment = var.env
  }
}
