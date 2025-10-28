module "mysql_db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "mysql-db-${var.project_name}-${var.env}"

  family               = "mysql5.7"
  engine               = "mysql"
  engine_version       = "5.7"
  major_engine_version = "5.7"
  instance_class       = "db.t3.micro"
  allocated_storage    = 5
  storage_encrypted    = false

  db_name  = var.db_name
  username = var.username
  password = var.password
  port     = "3306"

  manage_master_user_password = false
  create_db_option_group      = false

  multi_az = true

  iam_database_authentication_enabled = true

  vpc_security_group_ids = [aws_security_group.rds.id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # monitoring_interval    = "60"
  # monitoring_role_name   = "MyRDSMonitoringRole"
  # create_monitoring_role = true

  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name

  tags = merge({
    Name = "mysql-rds-${var.project_name}-${var.env}"
    Role = "database"
  }, var.tags)
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = var.private_subnet_ids # Debe tener subnets en al menos 2 AZs

  tags = merge(
    {
      Name = "rds-subnet-group-${var.project_name}-${var.env}"
    },
    var.tags,
  )
}

resource "aws_security_group" "rds" {
  name_prefix = "rds-sg-${var.project_name}-${var.env}"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from backend"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.backend_sg_id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}
