# Glossaire technique — TP IaC + Conteneurisation

> Référence rapide pour tous les termes techniques du projet, classés par thème.

---

## Infrastructure & Cloud

**AWS (Amazon Web Services)**
Plateforme cloud d'Amazon. On l'utilise pour louer des serveurs virtuels à la demande, payés à l'heure. On ne possède pas les machines, on les loue.

**EC2 (Elastic Compute Cloud)**
Le service AWS qui permet de créer des serveurs virtuels (appelés "instances"). C'est l'équivalent d'un PC dans le cloud. Tu choisis la taille (CPU, RAM), tu démarres, tu utilises, tu paies à l'heure, tu arrêtes.

**Instance**
Un serveur virtuel en cours d'exécution sur AWS. Quand on dit "une instance EC2 t3.micro", ça désigne un serveur avec 1 vCPU et 1 Go de RAM.

**t3.micro / t3.small**
Des tailles d'instances EC2. `t3.micro` = 1 vCPU + 1 Go RAM (souvent dans le Free Tier). `t3.small` = 2 vCPU + 2 Go RAM. Le préfixe `t3` désigne la famille d'instances à usage général d'AWS.

**Free Tier**
Offre gratuite d'AWS pour les nouveaux comptes : certaines ressources sont gratuites jusqu'à un quota mensuel (ex: 750h/mois d'instances t2.micro pendant 12 mois).

**IP publique**
Adresse réseau visible depuis Internet. Quand tu déploies sur AWS, ton serveur reçoit une IP publique que n'importe qui peut atteindre — ce qui permet à l'enseignant de tester ton app.

**Region / Zone de disponibilité**
AWS découpe le monde en régions géographiques (ex: `eu-west-3` = Paris). Chaque région a plusieurs zones de disponibilité (datacenters séparés). On choisit une région proche pour avoir moins de latence.

**Security Group**
Le pare-feu d'AWS. Définit quels ports sont ouverts ou fermés sur une instance EC2. On ouvrira uniquement les ports 80 (HTTP), 443 (HTTPS) et 22 (SSH pour administrer le serveur).

**VPC (Virtual Private Cloud)**
Réseau privé virtuel dans AWS. Toutes tes instances EC2 vivent dans un VPC. C'est l'équivalent d'un réseau local, mais dans le cloud.

---

## IaC & Terraform

**IaC (Infrastructure as Code)**
Principe qui consiste à décrire son infrastructure dans des fichiers de code (comme du code applicatif) plutôt que de la configurer manuellement dans une interface. Avantage : reproductible, versionnable, automatisable.

**Terraform**
Outil IaC créé par HashiCorp. Tu décris dans des fichiers `.tf` ce que tu veux comme infrastructure (VMs, réseaux, pare-feux…), et Terraform se charge de le créer ou le modifier chez le provider choisi (AWS, GCP, Proxmox…).

**OpenTofu**
Fork open-source de Terraform. Identique dans l'utilisation, créé après le changement de licence de Terraform en 2023. Les deux sont acceptés pour le TP.

**Provider Terraform**
Plugin qui permet à Terraform de communiquer avec un service spécifique (AWS, Docker, Kubernetes…). On déclare `provider "aws"` et Terraform sait comment créer des ressources AWS.

**Ressource Terraform**
Bloc de code `.tf` qui déclare un élément d'infrastructure à créer. Ex: `resource "aws_instance" "mon_serveur"` crée une instance EC2.

**Module Terraform**
Ensemble de ressources regroupées et réutilisables. Comme une fonction en programmation : tu l'appelles avec des paramètres et il crée un ensemble de ressources. Évite la duplication de code.

**`terraform plan`**
Commande qui simule ce que Terraform va faire sans rien modifier. Affiche ce qui sera créé, modifié ou détruit. À toujours faire avant `apply`.

**`terraform apply`**
Commande qui crée ou modifie réellement l'infrastructure selon les fichiers `.tf`. Demande une confirmation avant d'agir.

**`terraform destroy`**
Supprime toute l'infrastructure décrite dans les fichiers `.tf`. À utiliser après la correction pour ne pas payer.

**tfstate (terraform.tfstate)**
Fichier JSON que Terraform maintient pour se souvenir de l'état réel de l'infrastructure qu'il gère. Ne jamais commiter ce fichier dans git (contient des infos sensibles).

**tfvars (terraform.tfvars)**
Fichier contenant les valeurs des variables Terraform (clés AWS, mots de passe…). Ne jamais commiter dans git. On versionne un `.tfvars.example` avec des valeurs fictives à la place.

**Remote state**
Stocker le fichier `tfstate` à distance (ex: dans un bucket S3) plutôt qu'en local. Permet de partager l'état entre plusieurs personnes ou sessions.

**Backend**
Configuration Terraform qui indique où stocker le tfstate (local, S3, etc.).

---

## Docker & Conteneurisation

**Socket Docker (`/var/run/docker.sock`)**
Fichier spécial Unix via lequel on communique avec le démon Docker. En le montant dans Traefik, celui-ci peut interroger Docker en temps réel pour lire les labels des conteneurs et se reconfigurer automatiquement. Donner accès à ce fichier revient à donner les droits root sur la machine — à réserver à Traefik uniquement, en lecture seule (`:ro`).

**www-data**
Utilisateur système sous lequel Apache tourne à l'intérieur des conteneurs Debian/Ubuntu. C'est cet utilisateur qui lit les fichiers PHP et écrit dans le dossier `uploads/`. Le `chown www-data` dans le Dockerfile est indispensable pour que les uploads fonctionnent.

**Healthcheck**
Vérification périodique qu'un service est opérationnel. Dans docker-compose, le healthcheck sur MySQL envoie un `mysqladmin ping` toutes les 10 secondes. Tant que MySQL ne répond pas, Docker ne démarre pas le conteneur PHP (`depends_on: condition: service_healthy`).

**`exposedbydefault=false`**
Option Traefik qui désactive l'exposition automatique de tous les conteneurs Docker. Sans elle, MySQL serait accessible depuis l'extérieur via Traefik. Avec elle, seuls les conteneurs portant le label `traefik.enable=true` sont routés.

**`certresolver`**
Composant Traefik qui gère l'obtention automatique de certificats TLS via Let's Encrypt. Non utilisé dans ce projet (on utilise des certificats auto-signés à la place, générés nativement par Traefik quand `tls=true` est présent sans certresolver).

**Conteneur**
Processus isolé qui embarque tout ce dont une application a besoin pour tourner (code, dépendances, configuration). Léger et portable : tourne de la même façon sur n'importe quelle machine avec Docker installé.

**Image Docker**
Modèle en lecture seule à partir duquel on crée des conteneurs. C'est comme un template ou une "photo" d'un système avec une app installée. On la construit avec un Dockerfile.

**Dockerfile**
Fichier texte qui décrit comment construire une image Docker, étape par étape. Ex: "part de PHP 8, copie les fichiers de l'app, expose le port 80".

**docker-compose**
Outil qui permet de définir et lancer plusieurs conteneurs ensemble dans un fichier `docker-compose.yml`. Pratique pour lancer l'app PHP + la base de données en une seule commande.

**Registry**
Dépôt d'images Docker. Docker Hub est le registry public officiel (comme GitHub mais pour les images). On peut y pousser ses images pour les récupérer depuis un serveur distant.

**Volume Docker**
Mécanisme pour persister des données en dehors du conteneur. Sans volume, les données disparaissent quand le conteneur s'arrête. On utilise des volumes pour la base de données et le dossier `uploads`.

**Port mapping**
Associer un port du conteneur à un port de la machine hôte. Ex: `-p 8080:80` signifie "le port 80 du conteneur est accessible via le port 8080 de la machine".

**Labels Docker**
Métadonnées qu'on ajoute à un conteneur. Traefik les lit pour savoir comment router le trafic vers ce conteneur (quel domaine, quel port, quel TLS).

**Variables d'environnement**
Variables passées à un conteneur au démarrage pour configurer l'app sans modifier le code. Ex: `DB_PASSWORD=monmotdepasse`. Remplacent les valeurs hardcodées comme `root/root` dans `connect.php`.

---

## Kubernetes

**etcd**
Base de données clé-valeur qui stocke l'intégralité de l'état du cluster Kubernetes. Si etcd est perdu, tout l'état du cluster (quels pods tournent où, quelles configs existent) est perdu. C'est pourquoi il tourne uniquement sur le master et doit être sauvegardé régulièrement.

**kubelet**
Agent Kubernetes qui tourne sur chaque nœud worker. C'est lui qui reçoit les ordres du master ("démarre ce pod"), qui lance les conteneurs via Docker/containerd, et qui rapporte l'état des pods au control plane.

**ClusterIP**
Type de Service Kubernetes accessible uniquement depuis l'intérieur du cluster. Les pods se parlent entre eux via des ClusterIP (ex: le pod PHP accède à MySQL via `db-service:3306`). Le port MySQL n'est jamais exposé vers l'extérieur.

**Rolling update**
Stratégie de mise à jour Kubernetes sans interruption de service. K8s démarre les nouveaux pods avant d'arrêter les anciens. À tout moment, l'application reste disponible. C'est le comportement par défaut d'un Deployment.

**RBAC (Role-Based Access Control)**
Système de contrôle d'accès Kubernetes. Définit qui (utilisateur, pod, service account) peut faire quoi (lire, créer, supprimer) sur quelles ressources. Permet par exemple d'interdire à un pod d'application de lire les Secrets du cluster.

**Sealed Secrets**
Solution open-source (Bitnami) pour chiffrer les Secrets Kubernetes afin de pouvoir les commiter dans git. Un contrôleur dans le cluster déchiffre les SealedSecrets et crée les vrais Secrets K8s. Recommandé en production (hors périmètre de ce TP).

**SOPS**
Outil de chiffrement de fichiers (Mozilla). Alternative à Sealed Secrets pour protéger les secrets K8s ou Terraform. Chiffre les valeurs sensibles d'un YAML tout en laissant les clés lisibles.

**Provisioner Terraform**
Mécanisme Terraform pour exécuter des scripts sur une ressource après sa création. `remote-exec` se connecte en SSH à la VM et lance des commandes (installer Docker, k3s, etc.). À utiliser en dernier recours — préférer des outils dédiés (Ansible) pour la configuration logicielle.

**Kubernetes (K8s)**
Orchestrateur de conteneurs. Là où Docker fait tourner des conteneurs sur une machine, Kubernetes les fait tourner sur un **cluster** de plusieurs machines, gère leur répartition, leur redémarrage automatique, leur montée en charge, etc.

**k3s**
Distribution légère de Kubernetes créée par Rancher. Idéale pour des petites VMs (EC2 t3.small) car elle consomme peu de ressources. Kubernetes complet, simplement allégé.

**Cluster**
Ensemble de machines (nœuds) qui travaillent ensemble sous Kubernetes. Notre cluster aura 3 nœuds : 1 master + 2 workers.

**Nœud (Node)**
Une machine (VM EC2 dans notre cas) membre du cluster Kubernetes.

**Master / Control Plane**
Le nœud qui pilote le cluster : décide où placer les pods, gère l'état du cluster. Ne fait pas tourner les apps en production.

**Worker**
Nœud qui fait tourner les conteneurs applicatifs. Dans notre cluster : 2 workers EC2.

**Pod**
La plus petite unité déployable dans Kubernetes. Un pod contient un ou plusieurs conteneurs qui partagent le même réseau. En pratique, un pod = un conteneur pour nos besoins.

**Deployment**
Ressource K8s qui décrit comment déployer une app : quelle image Docker, combien de réplicas, comment mettre à jour. K8s s'assure que le nombre de pods souhaité tourne en permanence.

**Service**
Ressource K8s qui expose un Deployment sur le réseau interne du cluster. Sans service, les pods ne sont pas accessibles entre eux ni depuis l'extérieur.

**Ingress**
Ressource K8s qui définit les règles de routage HTTP/HTTPS vers les services. C'est ici qu'on dit "le domaine `app.local` doit aller vers le service PHP".

**Ingress Controller**
Le programme qui lit les ressources Ingress et fait concrètement le routage. Dans notre cas : Traefik déployé comme Ingress Controller.

**Namespace**
Espace de noms dans Kubernetes pour isoler des ressources. Comme des dossiers pour organiser les ressources d'un cluster.

**PVC (Persistent Volume Claim)**
Demande de stockage persistant dans Kubernetes. Un pod "réclame" X Go de stockage. K8s trouve un PV disponible et l'associe.

**PV (Persistent Volume)**
Volume de stockage réel disponible dans le cluster (disque local, NFS, EFS…). Les PVC se branchent sur des PV.

**ConfigMap**
Ressource K8s pour stocker de la configuration non-sensible (ex: URL de la base de données). Injectée dans les pods comme variable d'environnement.

**Secret**
Ressource K8s pour stocker des données sensibles (mots de passe, clés API) encodées en base64. Équivalent sécurisé du ConfigMap.

**Helm**
Gestionnaire de paquets pour Kubernetes. Un "Helm chart" est un paquet d'installation K8s préconfiguré. On l'utilisera pour installer Traefik sur le cluster en quelques commandes.

**kubectl**
La commande en ligne pour interagir avec un cluster Kubernetes. Équivalent de `docker` mais pour K8s.

**Manifest YAML**
Fichier YAML qui décrit une ressource Kubernetes (Deployment, Service, Ingress…). C'est le "code" des déploiements K8s.

---

## Réseau & Sécurité

**Blast radius**
Terme de sécurité qui désigne l'étendue des dégâts si un composant est compromis. Exemple : un conteneur qui tourne en `root` a un blast radius maximal (l'attaquant obtient les droits root sur l'hôte). Un conteneur qui tourne en `www-data` a un blast radius limité au seul dossier web.

**Man-in-the-middle (MitM)**
Attaque réseau où un attaquant intercepte les communications entre deux parties. Sans HTTPS, quelqu'un sur le même réseau Wi-Fi peut lire tous les échanges (mots de passe inclus). TLS chiffre les données et rend cette attaque inefficace.

**Reverse proxy**
Serveur intermédiaire placé devant une application. Reçoit les requêtes des utilisateurs et les redirige vers le bon service backend. Gère le TLS, le routage par domaine, et masque les ports internes.

**TLS / HTTPS / SSL**
Protocole de chiffrement des communications sur le web. HTTPS = HTTP + TLS. SSL est l'ancien nom de TLS. Quand tu vois le cadenas dans ton navigateur, c'est du TLS actif.

**Certificat TLS**
Fichier cryptographique qui prouve l'identité d'un serveur et permet de chiffrer les échanges. Un certificat signé par une autorité reconnue (Let's Encrypt) est valide dans tous les navigateurs. Un certificat auto-signé fonctionne mais affiche un avertissement.

**Certificat auto-signé**
Certificat TLS généré par soi-même, sans autorité de certification. Accepté pour ce TP. Le navigateur affichera une alerte que l'on peut passer manuellement.

**Port**
Numéro qui identifie un service réseau sur une machine. HTTP = 80, HTTPS = 443, MySQL = 3306, SSH = 22. On n'expose que les ports 80 et 443 au public.

**DNS (Domain Name System)**
Système qui traduit un nom de domaine (`app.local`) en adresse IP. Sans DNS, il faut taper une IP dans le navigateur.

**Fichier `hosts`**
Fichier local sur ta machine (et celle de l'enseignant) qui associe un nom de domaine à une IP sans passer par un serveur DNS. Ex: `54.12.34.56 app.local`. Solution simple pour ce TP.

**NFS (Network File System)**
Protocole de partage de fichiers sur le réseau. Sur K8s, permet à plusieurs pods (sur des nœuds différents) d'accéder au même dossier. Solution simple pour le stockage partagé.

**Longhorn**
Solution de stockage distribué pour Kubernetes. Plus robuste que NFS, mais plus complexe à installer.

**EFS (Elastic File System)**
Service de stockage partagé AWS. Équivalent managé de NFS, compatible K8s. Payant mais simple d'intégration.

---

## Base de données

**MySQL / MariaDB**
Systèmes de bases de données relationnelles. MySQL est propriété d'Oracle, MariaDB est le fork open-source communautaire. Compatibles entre eux, utilisés par l'app de base.

**PostgreSQL**
Autre système de base de données relationnelle open-source. Réputé plus avancé que MySQL. La partie "mise à jour" du TP consiste à migrer l'app de MySQL vers PostgreSQL.

**PDO (PHP Data Objects)**
Interface PHP pour communiquer avec des bases de données. Le `connect.php` de l'app utilise PDO — ce qui facilite la migration MySQL → PostgreSQL (on change juste le DSN de connexion).

**Dump SQL**
Fichier contenant les instructions SQL pour recréer une base de données (structure + données). Le fichier `database/gestion_produits.sql` est le dump de la base de test.

---

## Méthode & Organisation

**ADR (Architecture Decision Record)**
Document court qui capture une décision technique : le contexte, les options envisagées, le choix retenu et ses conséquences. Sert de mémoire du projet.

**GitOps**
Pratique qui consiste à utiliser git comme source de vérité pour l'infrastructure et les déploiements. Tout changement passe par un commit.

**CI/CD**
Continuous Integration / Continuous Deployment. Pipeline automatisé qui teste et déploie le code à chaque commit. Non requis pour ce TP mais mentionné dans les bonnes pratiques.

**SSH**
Protocole pour se connecter à distance à un serveur en ligne de commande de façon sécurisée. On utilisera SSH pour administrer les instances EC2.

**Clé SSH**
Paire de fichiers (clé privée + clé publique) pour s'authentifier sur un serveur sans mot de passe. La clé publique est déposée sur le serveur, la clé privée reste sur ta machine.
