terraform {
required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0.0"
    }
}
}
provider "aws" {
    profile = "aws-terraform-profile"                              //Profile to be used
    region = "us-east-1"                                           //Region
      assume_role {
    role_arn = "${var.provider_env_roles[terraform.workspace]}"    
  }
}

provider "aws" {
    profile = "aws-terraform-profile"                              //Profile to be used
    region = "us-east-2"
    alias  = "useast2"                                           //Region
      assume_role {
    role_arn = "${var.provider_env_roles[terraform.workspace]}"    
  }
}

  terraform {
      backend "s3" {
        bucket = "genaipoc-terraform-bucket"                        //S3 bucket to store terraform state (To be created by console)
        key = "terraform.state"
        region = "us-east-1"
        dynamodb_table = "terraform-state-lock"                     //Dynamo db table for terraform state locking (To be created by console)
        profile = "aws-terraform-profile"                           //Profile to be used


#         //for running code locally using aws secret key & access key specify this profile in  "vi ~/.aws/configure" in terminal
#         # [aws-terraform-profile]
#         # aws_access_key_id= <your-access-key>    
#         # aws_secret_access_key=<<your-secret-access-key>>
#         # aws_session_token=<your session token>
     }
 }