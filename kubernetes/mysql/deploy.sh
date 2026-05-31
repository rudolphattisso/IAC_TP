#!/bin/bash
# Script de déploiement complet de gestion-produits sur Kubernetes (variante MySQL)
# À exécuter depuis la racine du repo, kubeconfig configuré (voir output Terraform kubeconfig_command)
#
# Usage : bash kubernetes/mysql/deploy.sh VOTRE_DOCKERHUB

set -e

DOCKER_USER="${1:?Usage: $0 <docker-hub-username>}"
IMAGE="$DOCKER_USER/gestion-produits-mysql:latest"
NAMESPACE="gestion-produits"
SQL_FILE="gestion-produits/database/gestion_produits.sql"
MANIFESTS_DIR="kubernetes/mysql"

echo "=== 1/6 — Build et push de l'image Docker ==="
docker build -t "$IMAGE" -f docker/app/Dockerfile .
docker push "$IMAGE"

echo "=== 2/6 — Remplacement du placeholder image dans le deployment ==="
sed -i "s|VOTRE_DOCKERHUB/gestion-produits-mysql:latest|$IMAGE|g" \
  "$MANIFESTS_DIR/deployment-app.yaml"

echo "=== 3/6 — Création du namespace ==="
kubectl apply -f "$MANIFESTS_DIR/namespace.yaml"

echo "=== 4/6 — Création du ConfigMap SQL (initialisation de la base) ==="
kubectl create configmap db-init-sql \
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
kubectl rollout status deployment/db  -n "$NAMESPACE"
kubectl rollout status deployment/app -n "$NAMESPACE"

echo ""
echo "✓ Déploiement terminé"
echo "  Pods     : kubectl get pods -n $NAMESPACE"
echo "  Ingress  : kubectl get ingress -n $NAMESPACE"
echo "  App URL  : https://gestion-produits.local (ajouter l'IP master dans /etc/hosts)"
