data "http" "my_ip" {
  url = "https://ipv4.icanhazip.com"
}

locals {
  # Get my public IP address dynamically
  my_ip = chomp(data.http.my_ip.response_body)
}


resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg-${var.project_name}-${var.env}"
  description = "Security group for bastion"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow SSH from trusted IPs"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${local.my_ip}/32"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({
    Name = "bastion-sg-${var.project_name}-${var.env}"
  }, var.tags)
}

resource "aws_key_pair" "key_pair" {
  key_name   = "bastion-key-${var.project_name}-${var.env}"
  public_key = file(var.public_key_path)
}

resource "aws_instance" "bastion" {
  ami           = var.ami_id
  instance_type = "t3.micro"

  subnet_id              = var.public_subnet_ids[1]
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  associate_public_ip_address = true
  key_name                    = aws_key_pair.key_pair.key_name

  root_block_device {
    volume_size           = 10    # 10 GB
    volume_type           = "gp3" # General Purpose SSD (cost-effective)
    delete_on_termination = true
  }

  tags = merge({
    Name = "bastion-${var.project_name}-${var.env}"
  }, var.tags)
}
