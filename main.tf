provider "aws" {
  region = "us-east-2"
}

locals {
  env          = terraform.workspace
  project_name = "final-project"
  project_tags = {
    Terraform   = "true"
    Environment = local.env
    Project     = local.project_name
  }
}

check "valid_workspace" {
  assert {
    condition     = contains(["staging", "prod"], local.env)
    error_message = "Environment '${local.env}' is not valid. Must be staging or prod."
  }
}

# ---- Network Config ---- #
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   = "main-vpc-${local.project_name}"
  cidr   = "10.0.0.0/16"

  azs             = ["us-east-2a", "us-east-2b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_vpn_gateway = false

  tags = local.project_tags
}

# ---- AMI Data Source ---- #
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

# ---- Frontend Config ---- #
module "frontend" {
  source = "./modules/frontend"

  env          = local.env
  project_name = local.project_name

  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnets
  private_subnet_ids = module.vpc.private_subnets
  ami_id             = data.aws_ami.ubuntu.id

  tags = local.project_tags
}

# ---- Backend Config ---- #
module "backend" {
  source = "./modules/backend"

  env          = local.env
  project_name = local.project_name

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets
  ami_id             = data.aws_ami.ubuntu.id
  frontend_sg_id     = module.frontend.nodes_sg_id

  tags = local.project_tags
}

# ---- DataBase Config ---- #
module "database" {
  source = "./modules/database"

  env          = local.env
  project_name = local.project_name

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets
  backend_sg_id      = module.backend.nodes_sg_id

  db_name  = "final-project-db"
  username = var.db_user_name
  password = var.db_password

  tags = local.project_tags
}
