locals {
  db-ingress-rules = [
    {
      name        = "db-ingress-${var.db_port}-port-rule"
      cidr_block  = "0.0.0.0/0"
      from_port   = var.db_port
      to_port     = var.db_port
      ip_protocol = "tcp"
    }
  ]
  db-egress-rules = [
    {
      name        = "db-all-traffic-egress-rule"
      cidr_block  = "0.0.0.0/0"
      from_port   = 0
      to_port     = 0
      ip_protocol = "-1"
    }
  ]

}

resource "aws_subnet" "gtm-vpc-private-subnet1" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.cidr_block-for-subnet1
  map_public_ip_on_launch = false
  availability_zone       = var.db-availability-zone1

  tags = {
    Name = "private-db-subnet1"
  }

}

resource "aws_subnet" "gtm-vpc-private-subnet2" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.cidr_block-for-subnet2
  map_public_ip_on_launch = false
  availability_zone       = var.db-availability-zone2

  tags = {
    Name = "private-db-subnet2"
  }

}

resource "aws_db_subnet_group" "db-subnet-group" {
  subnet_ids = [aws_subnet.gtm-vpc-private-subnet1.id, aws_subnet.gtm-vpc-private-subnet2.id]
  tags = {
    Name = "db-subnet-group"
  }
}
resource "aws_security_group" "db-sec-group" {
  vpc_id = var.vpc_id
  tags = {
    Name = "db-security-group"
  }
}

#ingress rules.
module "security-group-ingress-rules" {
  source   = "../network-module/ingress"
  for_each = { for db-ingress_rule in local.db-ingress-rules : db-ingress_rule.name => db-ingress_rule }

  security-group-id        = aws_security_group.db-sec-group.id
  security-rule-cidr-block = each.value.cidr_block
  security-rule-from-port  = each.value.from_port
  security-rule-to-port    = each.value.to_port
  security-rule-protocol   = each.value.ip_protocol
  security-rule-tag-name   = each.value.name
}

#egress rule.
module "security-group-egress-rules" {
  source   = "../network-module/egress"
  for_each = { for db-egress_rule in local.db-egress-rules : db-egress_rule.name => db-egress_rule }

  security-group-id        = aws_security_group.db-sec-group.id
  security-rule-cidr-block = each.value.cidr_block
  security-rule-from-port  = each.value.from_port
  security-rule-to-port    = each.value.to_port
  security-rule-protocol   = each.value.ip_protocol
  security-rule-tag-name   = each.value.name
}