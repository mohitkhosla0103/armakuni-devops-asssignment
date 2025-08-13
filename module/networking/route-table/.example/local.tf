locals {
  
  pvt_subnets = flatten([
    {
      subnet_name = "pvt-sub-1"
      cidr_block  = "10.0.0.0/24"
      availability_zone = "us-east-1a"
    },
    {
      subnet_name = "pvt-sub-2"
      cidr_block  = "10.0.2.0/24"
      availability_zone = "us-east-1b"
    }
  ])

  pub_subnets = flatten([
    {
      subnet_name = "pub-sub-1"
      cidr_block  = "10.0.1.0/24"
      availability_zone = "us-east-1a"
    },
    {
      subnet_name = "pub-sub-2"
      cidr_block  = "10.0.3.0/24"
      availability_zone = "us-east-1b"
    }
  ])
  
  pub_subnet_ids = flatten([
    for subnet in module.pub-sub : subnet.id 
  ])

  pvt_subnet_ids = flatten([
    for subnet in module.pvt-sub : subnet.id 
  ])

}