variable "region" {
  default     = "us-west-2"
  description = "AWS cloud region"
  type        = string
}

variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  description = "VPC CIDR block"
  type        = string
}