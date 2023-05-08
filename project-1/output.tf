output "server_public_ip" {
  value = aws_eip.one.public_ip
}

output "server_private_ip" {
  value = aws_network_interface.web-server-nic.private_ips
}

output "firewall" {
  value = aws_security_group.allow_web.ingress
}