variable "project_name" {
  description = "Project name to be used in naming resources"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the RDS instance will be created"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
}

variable "db_name" {
  description = "Name of the database to be created"
  type        = string

}
variable "db_username" {
  description = "Username for the database"
  type        = string
}
variable "db_password" {
  description = "Password for the database"
  type        = string
  sensitive   = true
}

variable "private_subnets" {
  description = "List of private subnet IDs for the RDS instance"
  type        = list(string)
}
