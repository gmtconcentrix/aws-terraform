variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "db_port" {
  type    = number
  default = 3306
}

variable "cidr_block-for-subnet1" {
  type        = string
  description = "CIDR block for DB subnet1"
}

variable "cidr_block-for-subnet2" {
  type        = string
  description = "CIDR block for DB subnet2"
}

variable "db-availability-zone1" {
  type        = string
  description = "DB availability zone1"
  default     = "us-west-2b"
}
variable "db-availability-zone2" {
  type        = string
  description = "DB availability zone2"
  default     = "us-west-2c"
}
