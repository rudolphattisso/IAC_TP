output "master_public_ip" {
  description = "IP publique du master k3s"
  value       = module.k3s_master.public_ip
}

output "worker_public_ips" {
  description = "IPs publiques des workers k3s"
  value       = [for w in module.k3s_workers : w.public_ip]
}

output "ssh_master" {
  description = "Commande SSH pour accéder au master"
  value       = "ssh -i <ta-cle-privee>.pem ec2-user@${module.k3s_master.public_ip}"
}

output "kubeconfig_command" {
  description = "Commande pour récupérer le kubeconfig et accéder au cluster depuis ta machine"
  value       = "ssh -i <ta-cle-privee>.pem ec2-user@${module.k3s_master.public_ip} 'sudo cat /etc/rancher/k3s/k3s.yaml' | sed 's/127.0.0.1/${module.k3s_master.public_ip}/g' > ~/.kube/config"
}

output "hosts_entry" {
  description = "Ligne a ajouter dans le fichier hosts pour accéder à l'app"
  value       = "${module.k3s_master.public_ip}  gestion-produits.local"
}
