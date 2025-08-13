

provider "aws" {
    profile = "aws-terraform-profile"                              //Profile to be used
    region = var.secondary_region
    alias  =  "secondary"                                                                //Region
   
}


resource "aws_kms_key" "aurora_multi_region_key" {
  description             = "Multi-region KMS key for Aurora Global Cluster"
  enable_key_rotation     = false
  key_usage               = "ENCRYPT_DECRYPT"
  multi_region            = true
  
  tags = {
    Environment = "amano"
    Project     = "amano"
    terraform   = true
  }
}

resource "aws_kms_alias" "aurora_multi_region_key_alias" {
  name          = var.kms_aurora_alias_name
  target_key_id = aws_kms_key.aurora_multi_region_key.id
}

resource "aws_kms_replica_key" "aurora_multi_region_replica" {
    provider = aws.secondary
    
  primary_key_arn        = aws_kms_key.aurora_multi_region_key.arn
  description            = "Replicated KMS key for Aurora in secondary region"

  tags = {
    Environment = "amano"
    Project     = "amano"
    terraform   = true
  }
}




