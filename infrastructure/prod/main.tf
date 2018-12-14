provider "aws" {
  region  = "ap-northeast-1"
  version = "~> 1.39.0"
}

terraform {
  backend "s3" {
    bucket = "reizist-terraform-state"
    key = "apex/prod/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
module "sinatra_job" {
  source = "../modules/sinatra_job"
  apex_function_arns = "${var.apex_function_arns}"
  apex_function_names = "${var.apex_function_names}"
}