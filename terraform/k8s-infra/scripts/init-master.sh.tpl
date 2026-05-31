#!/bin/bash
set -e

# --- Installation de k3s en mode master ---
# K3S_TOKEN : token partagé entre tous les nœuds (défini par nous, pas généré aléatoirement)
# --write-kubeconfig-mode=644 : permet à ec2-user de lire le kubeconfig sans sudo
curl -sfL https://get.k3s.io | \
  K3S_TOKEN="${k3s_token}" \
  INSTALL_K3S_EXEC="--write-kubeconfig-mode=644" \
  sh -

systemctl enable k3s

echo "=== Master k3s installé ==="
echo "Token du cluster : ${k3s_token}"
echo "Vérifier les nœuds : kubectl get nodes"
