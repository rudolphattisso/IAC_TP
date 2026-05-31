# ADR-002 — Choix du reverse proxy

**Date :** 2026-05-30  
**Statut :** Accepté  
**Décideur :** Attisso Rudolph

## Contexte

Les deux infrastructures (Docker et Kubernetes) nécessitent un reverse proxy frontal pour exposer l'application uniquement sur les ports 80/443 et gérer le TLS.

## Options envisagées

- **Nginx** : très répandu, config statique manuelle, TLS via certbot séparé, intégration K8s via nginx-ingress-controller.
- **Traefik** : auto-discovery via labels Docker, Ingress Controller K8s intégré, TLS géré nativement.
- **Caddy** : TLS automatique, mais intégration K8s limitée.

## Décision

**Traefik**, pour les raisons suivantes :

- Côté Docker : configuration via labels dans `docker-compose.yml`, pas de fichiers de config séparés à maintenir
- Côté K8s : déployable comme Ingress Controller via Helm, utilise les ressources `Ingress` standards
- Un seul outil à maîtriser pour les deux environnements
- Aucune expérience préalable sur Nginx ou Traefik — Traefik réduit le volume de configuration manuelle

## Conséquences

- Moins de fichiers de configuration à écrire et maintenir
- TLS auto-signé géré nativement par Traefik (sans certbot)
- Nécessite d'apprendre la syntaxe des labels Traefik pour Docker
- Sur K8s, déploiement via Helm chart officiel Traefik
