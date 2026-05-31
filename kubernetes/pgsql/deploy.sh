#!/bin/bash
# Script de déploiement de la variante PostgreSQL sur Kubernetes
# À exécuter depuis la racine du repo, kubeconfig configuré
#
# Usage : bash kubernetes/pgsql/deploy.sh VOTRE_DOCKERHUB

set -e

DOCKER_USER="${1:?Usage: $0 <docker-hub-username>}"
IMAGE="$DOCKER_USER/gestion-produits-pgsql:latest"
NAMESPACE="gestion-produits"
SQL_FILE="gestion-produits/database/gestion_produits_pgsql.sql"
MANIFESTS_DIR="kubernetes/pgsql"

echo "=== 1/6 — Build et push de l'image Docker PostgreSQL ==="
docker build -t "$IMAGE" -f docker/app-pgsql/Dockerfile .
docker push "$IMAGE"

echo "=== 2/6 — Remplacement du placeholder image dans le deployment ==="
sed -i "s|VOTRE_DOCKERHUB/gestion-produits-pgsql:latest|$IMAGE|g" \
  "$MANIFESTS_DIR/deployment-app.yaml"

echo "=== 3/6 — Création du namespace ==="
kubectl apply -f "$MANIFESTS_DIR/namespace.yaml"

echo "=== 4/6 — Création du ConfigMap SQL PostgreSQL ==="
kubectl create configmap db-pgsql-init-sql \
  --from-file=init.sql="$SQL_FILE" \
  --namespace="$NAMESPACE" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "=== 5/6 — Application de tous les manifests ==="
kubectl apply -f "$MANIFESTS_DIR/secret.yaml"
kubectl apply -f "$MANIFESTS_DIR/pvc-db.yaml"
kubectl apply -f "$MANIFESTS_DIR/pvc-uploads.yaml"
kubectl apply -f "$MANIFESTS_DIR/deployment-db.yaml"
kubectl apply -f "$MANIFESTS_DIR/service-db.yaml"
kubectl apply -f "$MANIFESTS_DIR/deployment-app.yaml"
kubectl apply -f "$MANIFESTS_DIR/service-app.yaml"
kubectl apply -f "$MANIFESTS_DIR/ingress.yaml"

echo "=== 6/6 — Vérification ==="
kubectl rollout status deployment/db-pgsql  -n "$NAMESPACE"
kubectl rollout status deployment/app-pgsql -n "$NAMESPACE"

echo ""
echo "✓ Déploiement PostgreSQL terminé"
echo "  Pods    : kubectl get pods -n $NAMESPACE"
echo "  Ingress : kubectl get ingress -n $NAMESPACE"
echo "  App URL : https://gestion-produits-pgsql.local (ajouter l'IP master dans /etc/hosts)"
