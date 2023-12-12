data "aws_vpc" "default-vpc" {
  tags = {
    Name = "linux-vpc"
  }
}

data "aws_subnets" "default-public-subnet-one" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default-vpc.id]
  }
}

data "aws_subnet" "subnet_info" {
  id = data.aws_subnets.default-public-subnet-one.ids[0]
}


locals {
  vpc_id    = data.aws_vpc.default-vpc.id
  subnet_az = data.aws_subnet.subnet_info.availability_zone
  subnet_id = data.aws_subnets.default-public-subnet-one.ids[0]
}
