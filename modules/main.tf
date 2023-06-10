module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name   = "terraform_ec2_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDJSs8tx0ZQkfgYkOSLMWU9Sm8kHOGNaKcF4A5pkXyHqohUOLqMoP4iVBZv5kY8AGYuN/ITRsIcW7tzU/d13BdzFoTl/h9m6ICrcfhWkzFD6Apf1ClZZ5vmQ6r2wEQ3mM1tURUYPPaqLjCdC9E3gV8bu6XpNTwySUXBvfm3liDL4l1abfSRxWTLL9zlW543LtjWNs/nKivxSjsrpsK+kzAHZLSveFVmfj78TL6By7Tl4Hf2rWvUgSerihK7lU7MLT5u6nkcMpSB7hLn4ZDJ/0WGWreXhF7mPVQygtAjUSdkws0EgLm+HaGMLtya+Na1DevxJFW9lkkTCqx4O1rqwSYcN7so+vmlYnGDoluKVLFJS0/JpXPQZzHT+jMPTYHUuRMb43pYZGpaq/Vb6pTngb5hj1sN/F9jqbxabSe7tXPOgttbJlmYjIWqQ9TP8srwqS61jd8g9EUeJFM9BvhL8RRCKa+k1yHzyuvLH6b2nMHsxq6EihDRg7gRI/td9VFqciU= ubuntu@ip-172-31-92-226"
}

module "web_server_sg" {
  source = "terraform-aws-modules/security-group/aws//modules/http-80"

  name        = "web-server"
  description = "Allow SSH"
  vpc_id      = module.vpc.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "User-service ports"
      cidr_blocks = "0.0.0.0/0"
    }
 ]
}

module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "single-instance"
  ami  = "ami-053b0d53c279acc90"
  instance_type          = "t2.micro"
  key_name               = module.key_pair.key_pair_name
  monitoring             = true
  associate_public_ip_address = true
  vpc_security_group_ids = [module.web_server_sg.security_group_id]
  subnet_id              = module.vpc.public_subnets[0]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
