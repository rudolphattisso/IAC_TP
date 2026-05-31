# Méthode de travail — TP IaC + Conteneurisation avancée

> **Projet :** Déploiement automatisé d'une app PHP/MySQL sur Docker et Kubernetes  
> **Deadline :** 31 mai 2026 — minuit  
> **Modules évalués :** IaC–Terraform (20 pts) · Conteneurisation avancée (20 pts)

---

## 1. Posture de travail

**Mode guidance** : Claude oriente et recommande, le développeur décide et implémente.  
Chaque étape est discutée avant d'être réalisée. Aucune action automatique sans validation explicite.

**Traçabilité des décisions** : toute décision d'architecture ou de technologie est consignée sous forme d'ADR dans `doc/adr/` avant d'être implémentée.

---

## 2. Structure du dépôt cible

```
IAC_TP/
├── doc/
│   ├── methode-travail.md       ← ce fichier
│   ├── architecture.md          ← snapshot architecture (mis à jour à chaque ADR)
│   └── adr/
│       └── ADR-NNN-titre.md     ← une décision = un fichier
├── terraform/
│   ├── modules/                 ← modules réutilisables
│   ├── docker-infra/            ← infra Docker + reverse proxy
│   └── k8s-infra/               ← cluster K8s 3 nœuds
├── docker/
│   ├── app/                     ← Dockerfile PHP
│   ├── app-pgsql/               ← variante PostgreSQL
│   └── compose/                 ← docker-compose prod
└── kubernetes/
    ├── mysql/                   ← déploiement variante MySQL
    └── pgsql/                   ← déploiement variante PostgreSQL
```

---

## 3. Bonnes pratiques IaC (Terraform)

| Pratique | Pourquoi |
|---|---|
| Modules réutilisables | Évite la duplication entre infra Docker et K8s |
| `terraform.tfvars` hors git (`.gitignore`) | Ne jamais commiter de secrets |
| `terraform.tfvars.example` versionné | Documente les variables sans exposer les valeurs |
| Remote state (backend S3 / local selon choix infra) | Partage d'état entre sessions |
| `terraform plan` obligatoire avant `apply` | Valider l'impact avant d'agir |
| Variables pour tout ce qui change entre envs | Pas de valeurs hardcodées dans les ressources |

---

## 4. Normes de sécurité à respecter

### Secrets & credentials
- Aucun mot de passe, clé API ou token dans le code versionné
- Variables d'environnement injectées au runtime (Docker env / K8s Secrets)
- Les K8s Secrets doivent être encodés en base64 et idéalement chiffrés (Sealed Secrets ou SOPS)

### Réseau
- Application accessible uniquement via ports 80/443 (reverse proxy frontal)
- Pas d'exposition directe du port PHP ou de la base de données
- TLS obligatoire (certificats auto-signés acceptés, résolution via `/etc/hosts`)

### Conteneurs
- Ne pas utiliser `root` comme utilisateur dans les conteneurs
- Image de base officielle et minimale (ex: `php:8-apache` ou `php:8-fpm`)
- Dossier `uploads` en permission minimale nécessaire

### Base de données
- Changer les credentials par défaut (`root/root` actuels dans `connect.php`) dès la conteneurisation
- Créer un utilisateur dédié avec les droits minimum (pas `root`)

---

## 5. Gestion des ADR

### Format d'un ADR

```markdown
# ADR-NNN — Titre de la décision

**Date :** YYYY-MM-DD  
**Statut :** Proposé | Accepté | Remplacé par ADR-NNN  
**Décideur :** Attisso Rudolph

## Contexte
Pourquoi cette décision est nécessaire.

## Options envisagées
- Option A : ...
- Option B : ...

## Décision
Option choisie et justification.

## Conséquences
Ce que ça implique (positif et négatif).
```

### ADRs à créer (dans l'ordre)
- [ ] ADR-001 — Choix du provider d'infrastructure
- [ ] ADR-002 — Choix du reverse proxy (Nginx / Traefik / Caddy)
- [ ] ADR-003 — Stratégie de stockage partagé K8s
- [ ] ADR-004 — Gestion des secrets (K8s Secrets / Sealed Secrets)
- [ ] ADR-005 — Stratégie de migration MySQL → PostgreSQL

---

## 6. Optimisation des tokens — Choix du modèle

| Situation | Modèle recommandé | Pourquoi |
|---|---|---|
| Lire un fichier, chercher un pattern | **Haiku 4.5** | Rapide, économique |
| Générer du code (Terraform, Dockerfile, manifests K8s) | **Sonnet 4.6** | Bon équilibre qualité/coût |
| Décision d'architecture complexe, review de sécurité | **Opus 4.8** | Raisonnement profond quand ça compte |
| ADR, documentation technique | **Sonnet 4.6** | Suffisant pour la rédaction structurée |

**Règle générale :** commencer par Sonnet (défaut), descendre sur Haiku pour les tâches répétitives, monter sur Opus uniquement pour les décisions critiques.

### Mémoire architecture
Le fichier `doc/architecture.md` est le snapshot permanent de l'état du projet.  
À chaque session, Claude lit ce seul fichier au lieu de relire tout le repo — économie directe de tokens.

---

## 7. Phases de travail

```
Phase 1 — Décisions préliminaires (ADR-001 à ADR-002)
  └─ Choix provider infra + reverse proxy

Phase 2 — Conteneurisation locale
  ├─ Dockerfile PHP (app MySQL)
  ├─ docker-compose local (test)
  └─ Variante PostgreSQL

Phase 3 — Infrastructure Terraform
  ├─ Infra Docker + reverse proxy
  └─ Cluster K8s 3 nœuds

Phase 4 — Déploiement applicatif
  ├─ Docker prod (compose + reverse proxy TLS)
  └─ K8s (Deployments, Services, Ingress, PVC)

Phase 5 — Mise à jour PostgreSQL
  ├─ Dockerfile variante
  └─ URL dédiée sur les deux infras

Phase 6 — Documentation & livraison
  ├─ README technique
  └─ Envoi mail
```

---

## 8. Conventions de nommage

| Ressource | Convention | Exemple |
|---|---|---|
| Fichiers Terraform | `snake_case` | `main.tf`, `variables.tf`, `outputs.tf` |
| Ressources Terraform | `<type>_<nom>` | `vm_docker_host`, `node_k8s_worker` |
| Images Docker | `gestion-produits-<variant>` | `gestion-produits-mysql`, `gestion-produits-pgsql` |
| Manifests K8s | `<type>-<nom>.yaml` | `deployment-app.yaml`, `service-db.yaml` |
| ADR | `ADR-NNN-titre-kebab.md` | `ADR-001-choix-provider.md` |

---

## 9. Git — règles de commit

- Un commit = une modification logique
- Message format : `<type>: <description courte>`  
  Types : `feat`, `fix`, `terraform`, `docker`, `k8s`, `doc`, `security`
- Jamais de `tfstate`, `*.tfvars`, `.env` dans git (vérifier `.gitignore`)
