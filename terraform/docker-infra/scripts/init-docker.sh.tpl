#!/bin/bash
set -e

# --- Mise à jour système ---
dnf update -y
dnf install -y docker git

# --- Démarrage et activation de Docker ---
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

# --- Installation de Docker Compose v2 ---
mkdir -p /usr/local/lib/docker/cli-plugins
curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
  -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# --- Clonage du dépôt ---
git clone ${repo_url} /opt/app
cd /opt/app/docker/compose

# --- Création du fichier .env avec les variables injectées par Terraform ---
printf 'DB_USER=%s\n'             "${db_user}"             >  .env
printf 'DB_PASSWORD=%s\n'         "${db_password}"         >> .env
printf 'DB_NAME=%s\n'             "${db_name}"             >> .env
printf 'MYSQL_ROOT_PASSWORD=%s\n' "${mysql_root_password}" >> .env
printf 'PGSQL_USER=%s\n'          "${pgsql_user}"          >> .env
printf 'PGSQL_PASSWORD=%s\n'      "${pgsql_password}"      >> .env
printf 'PGSQL_DB=%s\n'            "${pgsql_db}"            >> .env

# --- Démarrage de l'application ---
docker compose up -d --build

echo "=== Déploiement terminé ==="
echo "Logs : docker compose -f /opt/app/docker/compose/docker-compose.yml logs -f"
