terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote state backend — prevents state corruption on concurrent runs
  backend "s3" {
    bucket         = "sugandha-tfstate-prod"
    key            = "aws-three-tier-arch/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "aws-three-tier-arch"
      Owner       = "sugandha-vashishtha"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

# ─────────────────────────────────────────────
# VPC
# ─────────────────────────────────────────────
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  environment          = var.environment
}

# ─────────────────────────────────────────────
# Application Load Balancer (Public)
# ─────────────────────────────────────────────
module "alb" {
  source = "./modules/alb"

  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnet_ids
  environment     = var.environment
}

# ─────────────────────────────────────────────
# EC2 Auto Scaling Group (Web Tier)
# ─────────────────────────────────────────────
module "ec2_web" {
  source = "./modules/ec2"

  vpc_id            = module.vpc.vpc_id
  private_subnets   = module.vpc.private_subnet_ids
  alb_sg_id         = module.alb.alb_security_group_id
  target_group_arn  = module.alb.target_group_arn
  instance_type     = var.instance_type
  ami_id            = var.ami_id
  min_size          = var.asg_min_size
  max_size          = var.asg_max_size
  desired_capacity  = var.asg_desired_capacity
  environment       = var.environment
}

# ─────────────────────────────────────────────
# RDS MySQL — Multi-AZ for High Availability
# ─────────────────────────────────────────────
module "rds" {
  source = "./modules/rds"

  vpc_id           = module.vpc.vpc_id
  private_subnets  = module.vpc.private_subnet_ids
  ec2_sg_id        = module.ec2_web.ec2_security_group_id
  db_name          = var.db_name
  db_username      = var.db_username
  db_password      = var.db_password
  instance_class   = var.db_instance_class
  environment      = var.environment
  # Multi-AZ enables automatic failover — RTO < 60 seconds
  multi_az         = true
}

# ─────────────────────────────────────────────
# CloudWatch Monitoring & Alarms
# ─────────────────────────────────────────────
module "cloudwatch" {
  source = "./modules/cloudwatch"

  asg_name         = module.ec2_web.asg_name
  alb_arn_suffix   = module.alb.alb_arn_suffix
  rds_identifier   = module.rds.db_identifier
  alarm_email      = var.alarm_email
  environment      = var.environment
}
