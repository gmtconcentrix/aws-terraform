output "db-subnet-group-name" {
  value = aws_db_subnet_group.db-subnet-group.name
}
output "db-security-group-id" {
  value = aws_security_group.db-sec-group.id
}