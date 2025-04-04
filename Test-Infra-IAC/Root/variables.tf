# Variables for root module

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "myapp"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# Database variables
variable "db_name" {
  description = "Name of the database"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Username for database"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Password for database"
  type        = string
  sensitive   = true
}

# EC2 variables
variable "ec2_ami" {
  description = "AMI ID for EC2 instance"
  type        = string
  default     = "ami-0e731c8a588258d0d" # Amazon Linux 2023 AMI (us-east-1)
}

variable "ec2_instance_type" {
  description = "Instance type for EC2"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}