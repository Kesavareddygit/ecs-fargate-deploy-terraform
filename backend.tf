provider "aws" {
  region     = var.region
  secret_key = ""
  access_key = ""
}


terraform {
 backend "s3" {
   encrypt        = false
   bucket         = "dev-tf-bucket-s3"
   dynamodb_table = "dev-terraform_state"
   key            = "path/path/terraform-tfstate"
   region         = "us-east-1"
 }
}
