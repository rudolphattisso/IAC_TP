# Gestion Produits — Déploiement IaC & Conteneurisation

Déploiement automatisé d'une application PHP/MySQL sur deux infrastructures (Docker et Kubernetes) provisionnées via Terraform sur AWS.

**Auteur :** Attisso Rudolph — M1 DEV EPSI  
**Modules évalués :** IaC–Terraform (20 pts) · Conteneurisation avancée (20 pts)

---

## Architecture globale

```mermaid
graph TD
    subgraph AWS["AWS — eu-west-3 (Paris)"]
        subgraph DockerInfra["EC2 t3.micro — Infra Docker"]
            T1["Traefik v3\n(reverse proxy + TLS)"]
            A1["PHP 8.2 / Apache\n(MySQL)"]
            A2["PHP 8.2 / Apache\n(PostgreSQL)"]
            DB1["MySQL 8.4"]
            DB2["PostgreSQL 16"]
            T1 --> A1 & A2
            A1 --> DB1
            A2 --> DB2
        end
        subgraph K8sInfra["3 EC2 t3.small — Cluster k3s"]
            Master["Master\n(Traefik Ingress)"]
            W1["Worker 1\nPods app"]
            W2["Worker 2\nPod MySQL / PostgreSQL"]
            Master --> W1 & W2
        end
    end
    Internet["🌐 Internet"] -->|":80/:443"| DockerInfra
    Internet -->|":80/:443"| K8sInfra
```

---

## Prérequis

### Outils à installer

| Outil | Version minimale | Usage |
|---|---|---|
| [Terraform](https://developer.hashicorp.com/terraform/install) | 1.5+ | Provisionnement AWS |
| [AWS CLI](https://aws.amazon.com/cli/) | 2.x | Authentification AWS |
| [Docker](https://docs.docker.com/get-docker/) | 24+ | Build et run des conteneurs |
| [kubectl](https://kubernetes.io/docs/tasks/tools/) | 1.28+ | Administration du cluster K8s |
| Compte [Docker Hub](https://hub.docker.com) | — | Registry des images |
| Compte AWS | — | Hébergement des EC2 |

### Configurer AWS

**1. Créer un utilisateur IAM avec droits admin :**
1. Console AWS → **IAM > Users > Create user**
2. Nom : `terraform-user`
3. **Attach policies directly** → `AdministratorAccess`
4. Onglet **Security credentials** → **Create access key** → CLI
5. Noter l'`Access Key ID` et le `Secret Access Key` (affichés une seule fois)

**2. Configurer AWS CLI :**
```bash
aws configure
# AWS Access Key ID     : <Access Key ID>
# AWS Secret Access Key : <Secret Access Key>
# Default region name   : eu-west-3
# Default output format : json
```

Vérifier :
```bash
aws sts get-caller-identity
```

**3. Créer une key pair SSH dans AWS Console :**
`EC2 > Key Pairs > Create key pair` — Type RSA, format `.pem` — télécharger et noter le nom.

### Cloner le dépôt

```bash
git clone https://github.com/rudolphattisso/IAC_TP.git
cd IAC_TP
```

---

## Structure du dépôt

```
IAC_TP/
├── docker/
│   ├── app/                     ← Dockerfile variante MySQL
│   ├── app-pgsql/               ← Dockerfile variante PostgreSQL
│   └── compose/                 ← docker-compose.yml (MySQL + PostgreSQL)
├── gestion-produits/
│   ├── php/www/                 ← code source PHP
│   └── database/
│       ├── gestion_produits.sql      ← schéma MySQL
│       └── gestion_produits_pgsql.sql ← schéma PostgreSQL
├── kubernetes/
│   ├── mysql/                   ← manifests K8s variante MySQL
│   └── pgsql/                   ← manifests K8s variante PostgreSQL
└── terraform/
    ├── modules/ec2/             ← module EC2 réutilisable
    ├── docker-infra/            ← infra Docker (1 EC2)
    └── k8s-infra/               ← cluster k3s (3 EC2)
```

---

## 1. Déploiement de l'infrastructure Docker

### Configuration

```bash
cd terraform/docker-infra
cp terraform.tfvars.example terraform.tfvars
```

Éditer `terraform.tfvars` :
```hcl
aws_region          = "eu-west-3"
key_name            = "nom-de-ta-key-pair"   # nom exact créé dans AWS Console
my_ip_cidr          = "TON_IP/32"            # curl ifconfig.me puis ajouter /32
repo_url            = "https://github.com/rudolphattisso/IAC_TP.git"
db_user             = "app"
db_password         = "MotDePasseFort1!"
db_name             = "gestion_produits"
mysql_root_password = "MotDePasseRoot1!"
pgsql_user          = "app_pgsql"
pgsql_password      = "MotDePasseFort1!"
pgsql_db            = "gestion_produits"
```

### Déploiement

```bash
terraform init
terraform plan
terraform apply
```

### Résultats

```bash
terraform output
# docker_host_ip = "X.X.X.X"
# hosts_entry    = "X.X.X.X  gestion-produits.local"
# ssh_command    = "ssh -i <cle>.pem ec2-user@X.X.X.X"
```

> L'application se déploie automatiquement au démarrage de l'instance via `user_data`.  
> Attendre ~3 minutes après `apply`.

Si les conteneurs ne sont pas démarrés, se connecter en SSH et les lancer manuellement :

```bash
ssh -i <cle>.pem ec2-user@X.X.X.X
sudo chown -R ec2-user:ec2-user /opt/app
cd /opt/app && git pull
docker compose -f /opt/app/docker/compose/docker-compose.yml up -d
```

### Vérification

```bash
docker compose -f /opt/app/docker/compose/docker-compose.yml ps
# Tous les conteneurs doivent être "healthy" ou "running"
```

Ajouter dans le fichier `hosts` (`/etc/hosts` ou `C:\Windows\System32\drivers\etc\hosts`) :
```
X.X.X.X  gestion-produits.local
X.X.X.X  gestion-produits-pgsql.local
```

Tester dans le navigateur :
- `https://gestion-produits.local` → variante MySQL
- `https://gestion-produits-pgsql.local` → variante PostgreSQL

> Alerte certificat TLS auto-signé — cliquer "Continuer quand même".

---

## 2. Déploiement de l'infrastructure Kubernetes

### Configuration

```bash
cd terraform/k8s-infra
cp terraform.tfvars.example terraform.tfvars
```

Éditer `terraform.tfvars` :
```hcl
aws_region = "eu-west-3"
key_name   = "nom-de-ta-key-pair"
my_ip_cidr = "TON_IP/32"
k3s_token  = "une-chaine-aleatoire-longue-et-complexe"
```

> Générer un token fort :
> - Linux/Mac : `openssl rand -hex 32`
> - Windows PowerShell : `-join ((1..64) | ForEach-Object { '{0:x}' -f (Get-Random -Max 16) })`

### Déploiement

```bash
terraform init
terraform plan
terraform apply
```

### Résultats

```bash
terraform output
# master_public_ip = "X.X.X.X"
# worker_public_ips = ["Y.Y.Y.Y", "Z.Z.Z.Z"]
# ssh_master = "ssh -i <cle>.pem ec2-user@X.X.X.X"
```

### Récupération du kubeconfig

**Linux / Mac :**
```bash
ssh -i <cle>.pem ec2-user@X.X.X.X \
  'sudo cat /etc/rancher/k3s/k3s.yaml' \
  | sed 's/127.0.0.1/X.X.X.X/g' > ~/.kube/config
```

**Windows (PowerShell) :**
```powershell
ssh -i "$env:USERPROFILE\<cle>.pem" ec2-user@X.X.X.X 'sudo cat /etc/rancher/k3s/k3s.yaml' `
  | ForEach-Object { $_ -replace '127.0.0.1', 'X.X.X.X' } `
  | Set-Content "$env:USERPROFILE\.kube\config"
```

Si kubectl retourne une erreur TLS (`x509: certificate is valid for ... not X.X.X.X`) :
```powershell
(Get-Content "$env:USERPROFILE\.kube\config") `
  -replace 'certificate-authority-data:.*', 'insecure-skip-tls-verify: true' `
  | Set-Content "$env:USERPROFILE\.kube\config"
```

Vérifier que les 3 nœuds sont `Ready` :
```bash
kubectl get nodes
```

---

## 3. Déploiement de l'application sur Kubernetes

> Depuis la **racine du dépôt** (`IAC_TP/`).

### Déploiement des manifests

```bash
kubectl apply -f kubernetes/mysql/
kubectl apply -f kubernetes/pgsql/
```

### Créer les ConfigMaps d'initialisation SQL

```bash
kubectl create configmap db-init-sql \
  --from-file=init.sql=gestion-produits/database/gestion_produits.sql \
  -n gestion-produits

kubectl create configmap db-pgsql-init-sql \
  --from-file=init.sql=gestion-produits/database/gestion_produits_pgsql.sql \
  -n gestion-produits
```

### Vérification

```bash
kubectl get pods    -n gestion-produits
kubectl get ingress -n gestion-produits
```

Tous les pods doivent être `1/1 Running`.

Mettre à jour le fichier `hosts` avec l'IP du master (remplacer ou commenter le bloc Docker) :
```
# X.X.X.X  gestion-produits.local        ← Docker (commenter pour tester K8s)
# X.X.X.X  gestion-produits-pgsql.local

Y.Y.Y.Y  gestion-produits.local           ← master_public_ip
Y.Y.Y.Y  gestion-produits-pgsql.local
```

Tester dans le navigateur :
- `https://gestion-produits.local` → variante MySQL sur K8s
- `https://gestion-produits-pgsql.local` → variante PostgreSQL sur K8s

---

## 4. Identifiants de connexion

| Infra | Variante | URL | Login | Mot de passe |
|---|---|---|---|---|
| Docker | MySQL | https://gestion-produits.local | admin | password |
| Docker | PostgreSQL | https://gestion-produits-pgsql.local | admin | password |
| Kubernetes | MySQL | https://gestion-produits.local | admin | password |
| Kubernetes | PostgreSQL | https://gestion-produits-pgsql.local | admin | password |

---

## 5. Nettoyage

```bash
# Supprimer l'infra Docker
cd terraform/docker-infra && terraform destroy

# Supprimer l'infra Kubernetes
cd terraform/k8s-infra && terraform destroy
```

> Détruire les infras après correction pour éviter des frais AWS.

---

## Captures d'écran — Déploiement réalisé

### Infrastructure Docker (EC2 t3.micro)

**Conteneurs en cours d'exécution (`docker compose ps`) :**

![Docker compose ps](doc/screenshots/docker-compose-ps.png)

**Application MySQL :**

![App MySQL Docker](doc/screenshots/docker-app-mysql.png)

**Application PostgreSQL :**

![App PostgreSQL Docker](doc/screenshots/docker-app-pgsql.png)

---

### Infrastructure Kubernetes (cluster k3s — 3 nœuds)

**Nœuds Ready (`kubectl get nodes`) :**

![Kubectl get nodes](doc/screenshots/k8s-nodes.png)

**Pods Running (`kubectl get pods -n gestion-produits`) :**

![Kubectl get pods](doc/screenshots/k8s-pods.png)

**Application MySQL :**

![App MySQL K8s](doc/screenshots/k8s-app-mysql.png)

**Application PostgreSQL :**

![App PostgreSQL K8s](doc/screenshots/k8s-app-pgsql.png)

---

## Décisions techniques

| ADR | Décision |
|---|---|
| ADR-001 | Provider : AWS EC2 + k3s |
| ADR-002 | Reverse proxy : Traefik v3 |
| ADR-003 | Stockage K8s : `local-path` (RWO) — provisioner natif k3s, stockage local au nœud. Solution légère adaptée à un déploiement mono-réplica sur EC2 sans EFS/NFS. Suffit pour le TP ; en production, remplacer par un StorageClass RWX (EFS, Longhorn…) pour le stockage partagé. |
| ADR-004 | Secrets K8s : Secrets natifs base64 |
| ADR-005 | Migration PostgreSQL : surcharge partielle Dockerfile |
| ADR-006 | Registry images : Docker Hub (ranawane93) |
