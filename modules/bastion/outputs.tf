output "bastion_ip" {
  value = aws_instance.bastion.public_ip
}

output "sg_id" {
  value = aws_security_group.bastion_sg.id
}
