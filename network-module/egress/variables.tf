variable "security-group-id" {
  type        = string
  description = "security group-id"
}

variable "security-rule-cidr-block" {
  type    = string
  default = "0.0.0.0/0"
}

variable "security-rule-from-port" {
  type        = number
  description = "From port for the rule"
}

variable "security-rule-to-port" {
  type        = number
  description = "To port for the rule"
}

variable "security-rule-protocol" {
  type        = string
  description = "IP Protocol"
}

variable "security-rule-tag-name" {
  type        = string
  default     = "default-tag"
  description = "Tag name for security rule"
}