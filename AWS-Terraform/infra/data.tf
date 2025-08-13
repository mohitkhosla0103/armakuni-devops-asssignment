
# # Data is used to get data from current aws infrastruture
# # Following will help us get the security groups that we can use in our terraform code
# #       according to terraform worskspaces(dev,stage,prod)

# # We have used below values in local.tf to allow access on specific ports to specific security groups.


#################################################################
#                          Security Groups                      #
#################################################################




# data "aws_security_group" "loadbalancer-sg" {
#   name = "${terraform.workspace}-loadbalancer-sg"
#   //depends_on = [module.security_group["dev-loadbalancer-sg"].sg_id]
   
# }


# #################################################################
# #                          AWS GENERAL                          #
# #################################################################

# data "aws_availability_zones" "available" {}

# data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# #################################################################
# #                          ACM                                  #
# #################################################################

# data "aws_acm_certificate" "issued" {
#   domain   = "dinolingo.com"
#   statuses = ["ISSUED"]
#   types = ["AMAZON_ISSUED"]
# }

# #################################################################
# #                          RDS                                  #
# #################################################################

data "aws_secretsmanager_secret_version" "demo_rds_creds" {
  secret_id = "demo_rds_creds"                               //name of secret
}
