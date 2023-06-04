terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region     = "us-east-1"
}

# Configure new provider block for different region
provider "aws" {
  alias      = "backup"
  region     = "us-west-1"
}
