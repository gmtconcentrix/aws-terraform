module "random-string-mod" {
  source = "../"
}

resource "aws_vpc_security_group_egress_rule" "egress-rule-with-given-port" {
  security_group_id = var.security-group-id
  cidr_ipv4         = var.security-rule-cidr-block
  from_port         = var.security-rule-from-port
  to_port           = var.security-rule-to-port
  ip_protocol       = var.security-rule-protocol

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      from_port, to_port, ip_protocol
    ]
  }
  tags = {
    Name = var.security-rule-tag-name == "default-tag" ? module.random-string-mod.random-string.value : var.security-rule-tag-name
  }
  description = "Security group for ${var.security-rule-protocol}"
}