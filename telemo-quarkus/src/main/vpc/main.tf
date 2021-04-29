terraform {
  required_providers {
    aws = {
      version = "~> 3.0"
    }
  }
}

data "aws_availability_zones" "available" {}

resource "aws_vpc" "telemo_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = "true"
  enable_dns_hostnames = "true"

  tags = {
    Name = "telemo_vpc"
  }
}

resource "aws_subnet" "telemo_net_pub_a" {
  vpc_id     = aws_vpc.telemo_vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "telemo_net_pub_a"
  }
}

resource "aws_subnet" "telemo_net_pub_b" {
  vpc_id     = aws_vpc.telemo_vpc.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "telemo_net_pub_b"
  }
}

resource "aws_subnet" "telemo_net_pub_c" {
  vpc_id     = aws_vpc.telemo_vpc.id
  cidr_block = "10.0.3.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = data.aws_availability_zones.available.names[2]

  tags = {
    Name = "telemo_net_pub_b"
  }
}

resource "aws_internet_gateway" "telemo_igw" {
  vpc_id = aws_vpc.telemo_vpc.id

  tags = {
    Name = "telemo_igw"
  }
}

resource "aws_route_table" "telemo_rt_pub" {
  vpc_id = aws_vpc.telemo_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.telemo_igw.id
  }
  tags = {
    Name = "telemo_rt_pub"
  }
}

resource "aws_route_table_association" "telemo_rt_assoc_a" {
  subnet_id      = aws_subnet.telemo_net_pub_a.id
  route_table_id = aws_route_table.telemo_rt_pub.id
}

resource "aws_route_table_association" "telemo_rt_assoc_b" {
  subnet_id      = aws_subnet.telemo_net_pub_b.id
  route_table_id = aws_route_table.telemo_rt_pub.id
}

resource "aws_route_table_association" "telemo_rt_assoc_c" {
  subnet_id      = aws_subnet.telemo_net_pub_c.id
  route_table_id = aws_route_table.telemo_rt_pub.id
}
