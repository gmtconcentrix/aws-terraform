resource "random_password" "db-password" {
  length           = 12
  special          = false
  min_numeric      = 1
  override_special = "@#!"
}

data "template_file" "db-cred-json" {
  template = file("./db-credentials-template.json")

  vars = {
    password = random_password.db-password.result
  }
}

locals {
  username = "admin"
  password = random_password.db-password.result
}

resource "random_integer" "secret-name-suffix" {
  min = 4
  max = 6
}

resource "aws_secretsmanager_secret" "gtm-db-secret" {
  name                           = "gtm-secret-name-${random_integer.secret-name-suffix.result}"
  force_overwrite_replica_secret = true
  tags = {
    Name = "gtm-db-secret-${random_integer.secret-name-suffix.result}"
  }
}

resource "aws_secretsmanager_secret_version" "secret-version-password" {
  secret_id     = aws_secretsmanager_secret.gtm-db-secret.id
  secret_string = data.template_file.db-cred-json.rendered
  depends_on = [
    aws_secretsmanager_secret.gtm-db-secret
  ]
}

resource "aws_db_instance" "mysql_db" {
  allocated_storage = 10
  identifier        = "gtmdb"
  db_name           = "gtmdb"
  engine            = "mysql"
  engine_version    = "5.7"
  instance_class    = "db.t3.micro"
  username          = local.username
  password          = local.password
  #parameter_group_name          = "default.mysql5.7"
  storage_type           = "gp2"
  publicly_accessible    = false
  skip_final_snapshot    = true
  db_subnet_group_name   = module.db-network-module.db-subnet-group-name
  vpc_security_group_ids = [module.db-network-module.db-security-group-id]
  blue_green_update {
    #Enable low-downtime updates 
    enabled = false
  }
  tags = {
    Name = "gtm-db"
  }
  depends_on = [
    aws_secretsmanager_secret_version.secret-version-password
  ]
}

module "db-network-module" {
  source                 = "./db-network-module"
  vpc_id                 = aws_vpc.gtm-vpc.id
  cidr_block-for-subnet1 = "10.0.2.0/24"
  cidr_block-for-subnet2 = "10.0.3.0/24"
  db_port                = 3306
  db-availability-zone1  = "us-west-2b"
  db-availability-zone2  = "us-west-2c"
}