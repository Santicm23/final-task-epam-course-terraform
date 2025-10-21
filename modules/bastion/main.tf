resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg-${var.project_name}-${var.env}"
  description = "Security group for bastion"
  vpc_id      = var.vpc_id

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


resource "aws_iam_role" "bastion_role" {
  name = "bastion-role-${var.project_name}-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "bastion_profile" {
  name = "bastion-profile-${var.project_name}-${var.env}"
  role = aws_iam_role.bastion_role.name
}

resource "aws_instance" "bastion" {
  ami           = var.ami_id
  instance_type = "t3.micro"

  subnet_id              = var.public_subnet_ids[1]
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.bastion_profile.name

  root_block_device {
    volume_size           = 10    # 10 GB
    volume_type           = "gp3" # General Purpose SSD (cost-effective)
    delete_on_termination = true
  }

  tags = merge({
    Name = "bastion-${var.project_name}-${var.env}"
  }, var.tags)
}

resource "aws_eip" "this" {
  domain   = "vpc"
  instance = aws_instance.bastion.id

  tags = merge({
    Name = "bastion-eip-${var.project_name}-${var.env}"
  }, var.tags)
}
