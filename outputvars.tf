output "vpc_id" {
  value = aws_vpc.gtm-vpc.id
}

output "ec2-public-ip" {
  value = aws_instance.ec2-instance.public_ip
}

output "db-endpoint" {
  value = aws_db_instance.mysql_db.endpoint
}

output "db-url" {
  value = aws_db_instance.mysql_db.address
}

output "db-subnet-group-name" {
  value = aws_db_instance.mysql_db.db_subnet_group_name
}

output "db-credentials-json" {
  value = data.template_file.db-cred-json.rendered
}

output "gtm-secret-name" {
  value = aws_secretsmanager_secret.gtm-db-secret.name
}

output "s3-deploy-bucket-id" {
  value = aws_s3_bucket.custom-s3-deploy-bucket.id
}