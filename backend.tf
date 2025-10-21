terraform {
  backend "s3" {
    bucket  = "final-task-tfbackend"
    key     = "terraform.tfstate"
    region  = "us-east-2"
    encrypt = true
  }
}
