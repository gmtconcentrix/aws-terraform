resource "aws_vpc" "gtm-vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "concentrix-gtm-vpc"
  }
}

resource "aws_subnet" "gtm-vpc-public-subnet" {
  vpc_id                  = aws_vpc.gtm-vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"

  tags = {
    Name = "ec2-public-subnet"
  }

}

resource "aws_internet_gateway" "gtm-vpc-gateway" {
  vpc_id = aws_vpc.gtm-vpc.id
  tags = {
    Name = "gtm-internet-gateway"
  }
}

resource "aws_route_table" "gtm-vpc-route-table" {
  vpc_id = aws_vpc.gtm-vpc.id
  tags = {
    Name = "gmt-vpc-route-table"
  }
}

resource "aws_route" "gtm-vpc-route" {
  route_table_id         = aws_route_table.gtm-vpc-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gtm-vpc-gateway.id

}

resource "aws_route_table_association" "route-assoc" {
  route_table_id = aws_route_table.gtm-vpc-route-table.id
  subnet_id      = aws_subnet.gtm-vpc-public-subnet.id
}

resource "aws_security_group" "ec2-sec-group-id" {
  vpc_id = aws_vpc.gtm-vpc.id
  tags = {
    Name = "EC2-security-group"
  }
}

locals {
  ingress-rules = [
    {
      name        = "ec2-ssh-ingress-rule"
      cidr_block  = "0.0.0.0/0"
      from_port   = 22
      to_port     = 22
      ip_protocol = "tcp"
    },
    {
      name        = "ec2-port-80-ingress-rule"
      cidr_block  = "0.0.0.0/0"
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
    },
    {
      name        = "ec2-port-8082-ingress-rule"
      cidr_block  = "0.0.0.0/0"
      from_port   = 8082
      to_port     = 8082
      ip_protocol = "tcp"
    },
    {
      name        = "ec2-port-3306-ingress-rule"
      cidr_block  = "0.0.0.0/0"
      from_port   = 3306
      to_port     = 3306
      ip_protocol = "tcp"
    }
  ]
  egress-rules = [
    {
      name        = "ec2-port-3306-egress-rule"
      cidr_block  = "0.0.0.0/0"
      from_port   = 3306
      to_port     = 3306
      ip_protocol = "tcp"
    },
    {
      name        = "ec2-all-ports-egress-rule"
      cidr_block  = "0.0.0.0/0"
      from_port   = 0
      to_port     = 0
      ip_protocol = "-1"
    }
  ]

}

/*
#Using count approach to iterate over list of custom objects
module "security-group-rules" {
  source = "./network-module"
  count  = length(local.ingress-rules)

  security-group-id        = aws_security_group.ec2-sec-group-id.id
  security-rule-cidr-block = local.ingress-rules[count.index].cidr_block
  security-rule-from-port  = local.ingress-rules[count.index].from_port
  security-rule-to-port    = local.ingress-rules[count.index].to_port
  security-rule-protocol   = local.ingress-rules[count.index].ip_protocol

}*/

#ingress rules.
module "security-group-ingress-rules" {
  source   = "./network-module/ingress"
  for_each = { for ingress_rule in local.ingress-rules : ingress_rule.name => ingress_rule }

  security-group-id        = aws_security_group.ec2-sec-group-id.id
  security-rule-cidr-block = each.value.cidr_block
  security-rule-from-port  = each.value.from_port
  security-rule-to-port    = each.value.to_port
  security-rule-protocol   = each.value.ip_protocol
  security-rule-tag-name   = each.value.name
}

#egress rule.
module "security-group-egress-rules" {
  source   = "./network-module/egress"
  for_each = { for egress_rule in local.egress-rules : egress_rule.name => egress_rule }

  security-group-id        = aws_security_group.ec2-sec-group-id.id
  security-rule-cidr-block = each.value.cidr_block
  security-rule-from-port  = each.value.from_port
  security-rule-to-port    = each.value.to_port
  security-rule-protocol   = each.value.ip_protocol
  security-rule-tag-name   = each.value.name
}