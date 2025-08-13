

tags = {
}

extra_tags = {
  Project          = "mohit-poc",
  Environment      = "dev",
  TerraformManaged = true // Add tags here

}


#################################################################
#                          Networking                           #
#################################################################


vpc_cidr              = "10.0.0.0/16" // Change CIDR Range
vpc_name              = "dev-vpc"
eip_name              = "dev-nat-elastic-ip"
nat_gateway_name      = "dev-nat-gateway"
internet_gateway_name = "dev-igw"
pub_route_table_name  = "dev-pub-route-table"
priv_route_table_name = "dev-pvt-route-table"
pub_route_dest_cidr   = "0.0.0.0/0"
priv_route_dest_cidr  = "0.0.0.0/0"



# # #################################################################
# # #                          Loadbalancer                         #
# # #################################################################


alb_name         = "mohit-dev-loadblancer"
is_alb_internal  = false
alb_idle_timeout = 60



# #################################################################
# #                          ECR                                  #
# #################################################################
repositories = {
  "dev-backend-dev-repo" = {
    name                 = "dev-backend-poc-repo"
    image_tag_mutability = "MUTABLE"
    scan_on_push         = true
    tags = {

    }
  }

}


# #################################################################
# #                          S3                                   #
# #################################################################

s3_bucket = {
  "dev-my-proj-artifact-bucket" = {
    bucket            = "dev-my-proj-artifact-bucket" //S3 to store source & build artifcats for CI-CD
    bucket_versioning = "Enabled"
  }
}





