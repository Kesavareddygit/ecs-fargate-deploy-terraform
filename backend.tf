provider "aws" {
  region     = var.region
  secret_key = ""
  access_key = ""
}


terraform {
 backend "s3" {
   encrypt        = false
   bucket         = "tf-bucket-s3-${ENV}"
   dynamodb_table = "${ENV}-terraform_state"
   key            = "path/path/terraform-tfstate"
   region         = "us-east-1"
 }
}
