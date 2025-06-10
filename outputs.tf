output "public_ip" {
  value       = aws_instance.ubuntu_server.public_ip
  description = "Public IPv4 of the EC2 instance"
}

output "ssh_command" {
  description = "SSH command to connect to the server"
  value       = "ssh -i ec2-ubuntu ubuntu@${aws_instance.ubuntu_server.public_ip}"
}
