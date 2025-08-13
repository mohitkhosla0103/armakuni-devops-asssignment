
terraform {
required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0.0"
    }
}
}

resource "aws_vpc" "a1-vpc" {
  cidr_block = var.a1_vpc_cidr_block
  enable_dns_hostnames = true
  tags = {
    Name = var.a1_vpc_name
    Project          = "Aurora-Module",
    Environment      = "poc"

  }
}


resource "aws_subnet" "public-1" {
  vpc_id     = "${aws_vpc.a1-vpc.id}"
  cidr_block = var.public_sn_1_cidr_block
  availability_zone = var.az_us_east_2a

  tags = {
    Name = var.public_sn_1_name
    Project          = "Aurora-Module",
  Environment      = "poc"
   
  }
}

resource "aws_subnet" "public-2" {
  vpc_id     = "${aws_vpc.a1-vpc.id}"
  cidr_block = var.public_sn_2_cidr_block
  availability_zone = var.az_us_east_2b

  tags = {
    Name = var.public_sn_2_name
    Project          = "Aurora-Module",
  Environment      = "poc"
   
  }
}

resource "aws_subnet" "private-services-1" {
  vpc_id     = "${aws_vpc.a1-vpc.id}"
  cidr_block = var.private_services_sn_1_cidr_block
  availability_zone = var.az_us_east_2a

  tags = {
    Name = var.private_services_sn_1_name
     Project          = "Aurora-Module",
  Environment      = "poc"
 
  
  }
}

resource "aws_subnet" "private-services-2" {
  vpc_id     = "${aws_vpc.a1-vpc.id}"
  cidr_block = var.private_services_sn_2_cidr_block
  availability_zone = var.az_us_east_2b

  tags = {
    Name = var.private_services_sn_2_name
     Project          = "Aurora-Module",
  Environment      = "poc"
 
  }
}

resource "aws_subnet" "private-db-1" {
  vpc_id     = "${aws_vpc.a1-vpc.id}"
  cidr_block = var.private_db_1_cidr_block
  availability_zone = var.az_us_east_2a

  tags = {
    Name = var.private_db_sn_1_name
     Project          = "Aurora-Module",
  Environment      = "poc"
  
  }
}

resource "aws_subnet" "private-db-2" {
  vpc_id     = "${aws_vpc.a1-vpc.id}"
  cidr_block = var.private_db_2_cidr_block
  availability_zone = var.az_us_east_2b

  tags = {
    Name = var.private_db_sn_2_name
     Project          = "Aurora-Module",
  Environment      = "poc"
  }
}

resource "aws_internet_gateway" "a1-gw" {
  vpc_id = "${aws_vpc.a1-vpc.id}"

  tags = {
    Name = var.igw_name
     Project          = "Aurora-Module",
  Environment      = "poc"
  }
}

resource "aws_eip" "ng-1" {
  domain = var.eip_domain

  tags = {
    Name = var.ng_1_name
     Project          = "Aurora-Module",
  Environment      = "poc"
  }
}
resource "aws_eip" "ng-2" {
  domain = var.eip_domain

  tags = {
    Name = var.ng_2_name
     Project          = "Aurora-Module",
  Environment      = "poc"
  }
}

resource "aws_nat_gateway" "ng-1" {
  allocation_id = "${aws_eip.ng-1.id}"
  subnet_id     = "${aws_subnet.public-1.id}"

  tags = {
    Name = var.nat_1_name
     Project          = "Aurora-Module",
  Environment      = "poc"
  }
}
resource "aws_nat_gateway" "ng-2" {
  allocation_id = "${aws_eip.ng-2.id}"
  subnet_id     = "${aws_subnet.public-2.id}"

  tags = {
    Name = var.nat_2_name
     Project          = "Aurora-Module",
  Environment      = "poc"
  }
}

resource "aws_route_table" "rt-public-subnets" {
  vpc_id = "${aws_vpc.a1-vpc.id}"

  route {
    cidr_block = var.allow_all_cidr_block
    gateway_id = "${aws_internet_gateway.a1-gw.id}"
  }

  tags = {
    Name = var.public_rt_name
     Project          = "Aurora-Module",
  Environment      = "poc"
  }
}

resource "aws_route_table_association" "rt-assoc-public-2a" {
  subnet_id      = "${aws_subnet.public-1.id}"
  route_table_id = "${aws_route_table.rt-public-subnets.id}"
}

resource "aws_route_table_association" "rt-assoc-public-2b" {
  subnet_id      = "${aws_subnet.public-2.id}"
  route_table_id = "${aws_route_table.rt-public-subnets.id}"
}

resource "aws_route_table" "rt-private-service-1" {
  vpc_id = "${aws_vpc.a1-vpc.id}"

  route {
    cidr_block = var.allow_all_cidr_block
    nat_gateway_id = "${aws_nat_gateway.ng-1.id}"
  }

  tags = {
    Name = var.private_rt_1_name
     Project          = "Aurora-Module",
  Environment      = "poc"

  }
}
resource "aws_route_table_association" "rt-assoc-private-1" {
  subnet_id      = "${aws_subnet.private-services-1.id}"
  route_table_id = "${aws_route_table.rt-private-service-1.id}"
}

resource "aws_route_table" "rt-private-service-2" {
  vpc_id = "${aws_vpc.a1-vpc.id}"

  route {
    cidr_block = var.allow_all_cidr_block
    nat_gateway_id = "${aws_nat_gateway.ng-2.id}"
  }

  tags = {
    Name = var.private_rt_2_name
     Project          = "Aurora-Module",
  Environment      = "poc"
  }
}

resource "aws_route_table_association" "rt-assoc-private-2" {
  subnet_id      = "${aws_subnet.private-services-2.id}"
  route_table_id = "${aws_route_table.rt-private-service-2.id}"
}

output "vpc_id" {
    value = "${aws_vpc.a1-vpc.id}"
}

output "eks_subnets_ids" {
    value = ["${aws_subnet.private-services-1.id}", "${aws_subnet.private-services-2.id}"]
}

output "db_subnet_ids" {
    value = ["${aws_subnet.private-db-1.id}", "${aws_subnet.private-db-2.id}"]
}

output "eks_subnet_cidrs" {
  value = ["${aws_subnet.private-services-1.cidr_block}", "${aws_subnet.private-services-2.cidr_block}"]
}

output "public_subnet_ids" {
  value = ["${aws_subnet.public-1.id}", "${aws_subnet.public-2.id}"]
}

