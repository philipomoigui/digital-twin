terraform {
  backend "s3" {
    bucket         = "twin-terraform-state-180294197745"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "twin-terraform-locks"
    encrypt        = true
  }
}

