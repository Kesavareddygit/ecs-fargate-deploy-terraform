provider "aws" {
  region     = var.region
  secret_key = ""
  access_key = ""
}


terraform {
 backend "s3" {
   encrypt        = false
   bucket         = "tf-bucket-s3-dev"
   key            = "path/path/terraform-tfstate"
   dynamodb_table = "dev-terraform-state"
   region         = "us-east-1"
 }
}
