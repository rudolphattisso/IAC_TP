#!/bin/bash
set -e

# --- Installation de k3s en mode master ---
# K3S_TOKEN : token partagé entre tous les nœuds (défini par nous, pas généré aléatoirement)
# --write-kubeconfig-mode=644 : permet à ec2-user de lire le kubeconfig sans sudo
# --tls-san : ajoute l'IP publique EC2 dans les SANs du certificat TLS (nécessaire pour kubectl depuis l'extérieur)
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

curl -sfL https://get.k3s.io | \
  K3S_TOKEN="${k3s_token}" \
  INSTALL_K3S_EXEC="--write-kubeconfig-mode=644 --tls-san $PUBLIC_IP" \
  sh -

systemctl enable k3s

echo "=== Master k3s installé ==="
echo "Vérifier les nœuds : kubectl get nodes"
