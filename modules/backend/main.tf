module "alb_backend" {
  source = "terraform-aws-modules/alb/aws"

  name    = "alb-back-${var.project_name}-${var.env}"
  vpc_id  = var.vpc_id
  subnets = var.private_subnet_ids

  enable_deletion_protection = false

  security_group_ingress_rules = {
    all_http = {
      from_port                    = 80
      to_port                      = 80
      ip_protocol                  = "tcp"
      description                  = "HTTP web traffic"
      referenced_security_group_id = var.frontend_sg_id
    }
    all_https = {
      from_port                    = 443
      to_port                      = 443
      ip_protocol                  = "tcp"
      description                  = "HTTPS web traffic"
      referenced_security_group_id = var.frontend_sg_id
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"

      forward = {
        target_group_key = "tg_backend"
      }
    }
  }

  target_groups = {
    tg_backend = {
      name_prefix = "back"
      protocol    = "HTTP"
      port        = 80
      target_type = "instance"
      health_check = {
        path                = "/"
        matcher             = "200-399"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        interval            = 30
        timeout             = 5
      }
      create_attachment = false
    }
  }

  tags = merge({
    Name = "alb-backend-${var.project_name}-${var.env}"
  }, var.tags)
}

resource "aws_lb_target_group_attachment" "backend_instances" {
  count            = length(aws_instance.backend_nodes)
  target_group_arn = module.alb_backend.target_groups["tg_backend"].arn
  target_id        = aws_instance.backend_nodes[count.index].id
  port             = 80
}

resource "aws_security_group" "backend_nodes_sg" {
  name        = "backend-nodes-sg-${var.project_name}-${var.env}"
  description = "Security group for nodes"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow SSH from bastion SG"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [var.bastion_sg]
  }

  ingress {
    description     = "Allow HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [module.alb_backend.security_group_id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "backend-nodes-sg-${var.project_name}-${var.env}"
  })
}

resource "aws_key_pair" "key_pair" {
  key_name   = "backend-key-${var.project_name}-${var.env}"
  public_key = file(var.public_key_path)
}

resource "aws_instance" "backend_nodes" {
  count         = 2
  ami           = var.ami_id
  instance_type = "t3.micro"

  key_name = aws_key_pair.key_pair.key_name

  subnet_id              = var.private_subnet_ids[count.index % length(var.private_subnet_ids)]
  vpc_security_group_ids = [aws_security_group.backend_nodes_sg.id]


  root_block_device {
    volume_size           = 10    # 10 GB
    volume_type           = "gp3" # General Purpose SSD (cost-effective)
    delete_on_termination = true
  }

  tags = merge(var.tags, {
    Name = "backend-node${count.index}-${var.project_name}-${var.env}"
  })
}
