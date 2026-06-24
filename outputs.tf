output "instance_id" {
  description = "ID of the EC2 instance."
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "Public IP address of the EC2 instance."
  value       = aws_instance.web.public_ip
}

output "public_dns" {
  description = "Public DNS name of the EC2 instance."
  value       = aws_instance.web.public_dns
}

output "website_url" {
  description = "Open this URL in your browser to view the website."
  value       = "http://${aws_instance.web.public_ip}"
}

output "ssh_command" {
  description = "Convenience SSH command (requires a key pair)."
  value       = var.key_pair_name != "" ? "ssh -i ${var.key_pair_name}.pem ec2-user@${aws_instance.web.public_ip}" : "No key pair configured."
}
