# Main Terraform configuration file

provider "aws" {
  region = var.region
}

# VPC Module
module "vpc" {
  source = "../Modules/vpc"

  vpc_cidr             = var.vpc_cidr
  environment          = var.environment
  availability_zones   = ["${var.region}a", "${var.region}b"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
}

# RDS Module
module "rds" {
  source = "../Modules/rds"

  project_name    = var.project_name
  environment     = var.environment
  vpc_id          = module.vpc.vpc_id
  vpc_cidr        = var.vpc_cidr
  private_subnets = module.vpc.private_subnet_ids
  db_name         = var.db_name
  db_username     = var.db_username
  db_password     = var.db_password
}

# EC2 Security Group
resource "aws_security_group" "ec2_sg" {
  name   = "${var.project_name}-${var.environment}-ec2-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "web" {
  ami                    = var.ec2_ami
  instance_type          = var.ec2_instance_type
  subnet_id              = module.vpc.public_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = var.key_name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "Hello from ${var.project_name} ${var.environment} environment" > /var/www/html/index.html
              EOF

  tags = {
    Name = "${var.project_name}-${var.environment}-web"
  }
}