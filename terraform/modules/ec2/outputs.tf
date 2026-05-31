output "public_ip" {
  description = "Adresse IP publique de l'instance"
  value       = aws_instance.this.public_ip
}

output "private_ip" {
  description = "Adresse IP privée de l'instance (réseau interne AWS)"
  value       = aws_instance.this.private_ip
}

output "instance_id" {
  description = "Identifiant unique de l'instance EC2"
  value       = aws_instance.this.id
}
