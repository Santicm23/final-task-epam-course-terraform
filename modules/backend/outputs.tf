output "nodes_sg_id" {
  value = aws_security_group.backend_nodes_sg.id
}

output "alb_url" {
  value = module.alb_backend.dns_name
}
