terraform {
  backend "s3" {
    bucket         = "prodiostore"
    key            = "main/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "Prodiotftable"
  }
}