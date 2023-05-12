terraform {
  # Partial backend configuration.
  #backend "s3" {}
  #backend "s3" {
  #  # This may not be the correct name if we destroy the s3 bucket and then later re-create it.
  #  bucket         = "terraform-training20230509204229968600000001"
  #  key            = "terraform/states/vm"
  #  region         = "us-east-1"
  #  dynamodb_table = "terraform-training"
  #}


  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"

    }
  }
}



# Configured via environment variables.
provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "sudomateo" {
  key_name_prefix = "sudomateo"
  public_key      = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMb0cVbN/fXyj9CEsCl7APDFBjqFpVXG3gBaI4OET646"
}

module "sudomateo_vm" {
  source = "github.com/sudomateo/terraform-aws-terraform-training-vm?ref=main"

  for_each = {
    foo = {
      ingress_rules = [
        {
          description = "SSH"
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
        },
      ]
    }
  }

  name          = each.key
  key_name      = aws_key_pair.sudomateo.key_name
  ingress_rules = each.value.ingress_rules
}
