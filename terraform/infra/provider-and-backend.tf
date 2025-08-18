terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0.0"
    }
  }
}
provider "aws" {
  #profile = "aws-terraform-profile" //Profile to be used
  region = "us-east-1" //Region
  #assume_role {
  #role_arn = var.provider_env_roles[terraform.workspace]
  #}
}


terraform {
  backend "s3" {
    bucket = "mohit-terraform-statefile" //S3 bucket to store terraform state (To be created by console)
    key    = "terraform.state"
    region = "us-east-1"
    #profile      = "aws-terraform-profile" //Profile to be used
    use_lockfile = true


    #         //for running code locally using aws secret key & access key specify this profile in  "vi ~/.aws/configure" in terminal
    #         # [aws-terraform-profile]
    #         # aws_access_key_id= <your-access-key>    
    #         # aws_secret_access_key=<<your-secret-access-key>>
    #         # aws_session_token=<your session token>
  }
}
