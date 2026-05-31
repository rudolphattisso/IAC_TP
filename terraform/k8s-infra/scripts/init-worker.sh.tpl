#!/bin/bash
set -e

# --- Installation de k3s en mode worker (agent) ---
# K3S_URL    : adresse IP privée du master (réseau interne AWS, pas d'Internet)
# K3S_TOKEN  : même token que le master — authentifie le worker auprès du cluster
curl -sfL https://get.k3s.io | \
  K3S_URL="https://${master_private_ip}:6443" \
  K3S_TOKEN="${k3s_token}" \
  sh -

systemctl enable k3s-agent

echo "=== Worker k3s installé ==="
echo "Master : ${master_private_ip}"
