output "docker_host_ip" {
  description = "IP publique du serveur Docker"
  value       = module.docker_host.public_ip
}

output "ssh_command" {
  description = "Commande SSH pour se connecter au serveur"
  value       = "ssh -i <ta-cle-privee>.pem ec2-user@${module.docker_host.public_ip}"
}

output "hosts_entry" {
  description = "Ligne a ajouter dans /etc/hosts (ou C:\\Windows\\System32\\drivers\\etc\\hosts)"
  value       = "${module.docker_host.public_ip}  gestion-produits.local"
}

output "app_url" {
  description = "URL de l'application apres configuration du fichier hosts"
  value       = "https://gestion-produits.local"
}
