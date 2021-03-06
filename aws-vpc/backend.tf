terraform {
  backend "s3" {
    bucket  = "acmeco-terraform-remote-states"
    key     = "dev/vpc-terraform.tfstate"
    region  = "us-east-1"
    encrypt = true

    dynamodb_table = "terraform-state-locks"
  }
}

