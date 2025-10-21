module "alb_frontend" {
  source = "terraform-aws-modules/alb/aws"

  name    = "alb-front-${var.project_name}-${var.env}"
  vpc_id  = var.vpc_id
  subnets = var.public_subnet_ids

  enable_deletion_protection = false

  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "HTTPS web traffic"
      cidr_ipv4   = "0.0.0.0/0"
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
        target_group_key = "tg_frontend"
      }
    }
  }

  target_groups = {
    tg_frontend = {
      name_prefix = "front"
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
    Name = "alb-frontend-${var.project_name}-${var.env}"
  }, var.tags)
}

resource "aws_lb_target_group_attachment" "frontend_instances" {
  count            = length(aws_instance.frontend_nodes)
  target_group_arn = module.alb_frontend.target_groups["tg_frontend"].arn
  target_id        = aws_instance.frontend_nodes[count.index].id
  port             = 80
}

resource "aws_security_group" "frontend_nodes_sg" {
  name        = "frontend-nodes-sg-${var.project_name}-${var.env}"
  description = "Security group for nodes"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [module.alb_frontend.security_group_id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "frontend-nodes-sg-${var.project_name}-${var.env}"
  })
}

resource "aws_instance" "frontend_nodes" {
  count         = 2
  ami           = var.ami_id
  instance_type = "t3.micro"

  subnet_id              = var.private_subnet_ids[count.index % length(var.private_subnet_ids)]
  vpc_security_group_ids = [aws_security_group.frontend_nodes_sg.id]

  user_data = <<-EOF
             #!/bin/bash
             exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

             echo "Starting user data script..."
             apt-get update -y
             apt-get install -y nginx

             # Crear página web con información de la instancia
             cat > /var/www/html/index.html << EOL
             <!DOCTYPE html>
             <html>
             <head>
                 <title>Instance ${count.index + 1}</title>
                 <style>
                     body { font-family: Arial, sans-serif; text-align: center; margin: 50px; }
                     .container { background: #f0f0f0; padding: 20px; border-radius: 10px; }
                 </style>
             </head>
             <body>
                 <div class="container">
                     <h1>Hello from Instance ${count.index + 1}</h1>
                     <p>Server: $(hostname)</p>
                     <p>IP: $(hostname -I)</p>
                     <p>Date: $(date)</p>
                 </div>
             </body>
             </html>
             EOL

             # Configurar nginx
             systemctl enable nginx
             systemctl start nginx

             # Verificar que nginx está corriendo
             systemctl status nginx

             echo "User data script completed successfully"
             EOF


  root_block_device {
    volume_size           = 10    # 10 GB
    volume_type           = "gp3" # General Purpose SSD (cost-effective)
    delete_on_termination = true
  }

  tags = merge(var.tags, {
    Name = "frontend-node${count.index}-${var.project_name}-${var.env}"
  })
}
