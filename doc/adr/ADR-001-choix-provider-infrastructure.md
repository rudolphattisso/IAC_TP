# ADR-001 — Choix du provider d'infrastructure

**Date :** 2026-05-30  
**Statut :** Accepté  
**Décideur :** Attisso Rudolph

## Contexte

Le sujet impose de déployer deux infrastructures (Docker + Kubernetes 3 nœuds) en les provisionnant via Terraform. L'infrastructure doit être **facilement accessible** pour que l'enseignant puisse tester le travail rendu.

## Options envisagées

- **VMs locales** (VirtualBox / libvirt) : gratuit, mais non accessible à distance, dépendant de l'hyperviseur local — ne satisfait pas la contrainte d'accessibilité du sujet.
- **Proxmox** : bon provider Terraform, mais nécessite un serveur dédié non disponible.
- **AWS (EC2)** : IP publique, Terraform provider officiel et très documenté, Free Tier utilisable pour les instances de test, détruire après correction = coût négligeable.
- **EKS (AWS Kubernetes managé)** : trop coûteux et hors sujet — le sujet demande de déployer soi-même le cluster.

## Décision

**AWS avec instances EC2**, sans services managés K8s (pas d'EKS).

- Infra Docker : **1 instance EC2** (t3.micro — Free Tier eligible)
- Infra K8s : **3 instances EC2** (t3.small — master × 1 + workers × 2)

K8s sera installé avec **k3s** (distribution légère, parfaite pour des EC2 de petite taille).

## Conséquences

- L'enseignant peut accéder à l'app via IP publique AWS sans configuration locale
- Le code Terraform est reproductible avec n'importe quel compte AWS
- Coût estimé : < 0,50 € pour la durée du TP (à détruire après correction)
- Nécessite de gérer les credentials AWS (Access Key / Secret Key) hors du repo git
