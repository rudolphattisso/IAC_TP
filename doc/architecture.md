# Architecture snapshot — IAC_TP

> Fichier maintenu à jour à chaque ADR. Lire ce fichier en début de session pour éviter de relire tout le repo.  
> Dernière mise à jour : 2026-05-30

---

## Application source

- **Repo :** `gestion-produits/` (cloné)
- **Stack :** PHP 8 + MySQL 8.4
- **Point d'entrée BD :** `connect.php` — host=`db`, user=`root`, pass=`root`, db=`gestion_produits`
- **Credentials à remplacer** en prod (ADR à créer)
- **Dossier uploads :** `php/www/uploads/` — nécessite r/w

## Structure du dépôt (cible)

```
IAC_TP/
├── doc/
│   ├── methode-travail.md
│   ├── architecture.md          ← ce fichier
│   └── adr/
├── terraform/
│   ├── modules/
│   ├── docker-infra/
│   └── k8s-infra/
├── docker/
│   ├── app/                     ← Dockerfile MySQL
│   ├── app-pgsql/               ← Dockerfile PostgreSQL
│   └── compose/
└── kubernetes/
    ├── mysql/
    └── pgsql/
```

## Décisions actées (ADR)

| ADR | Titre | Statut |
|---|---|---|
| ADR-001 | Choix du provider d'infrastructure → AWS EC2 + k3s | Accepté |
| ADR-002 | Choix du reverse proxy → Traefik | Accepté |

## Contraintes connues

- Accès uniquement ports 80/443
- TLS auto-signé (pas d'achat de domaine)
- Résolution DNS via `/etc/hosts` ou DNS local
- K8s : 3 nœuds + solution stockage partagé à définir
- Deadline : 31 mai 2026 minuit
