terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket         = "techlab-infraestructure-dev-rds"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    # Replace this with your DynamoDB table name!
    dynamodb_table = "techlab-infraestructure-dev-rds"
    encrypt        = true
  }
}
