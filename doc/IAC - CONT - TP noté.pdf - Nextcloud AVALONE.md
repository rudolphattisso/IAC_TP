# IaC – Terraform – Conteneurisation avancée
## TP noté – M1 DEV

HashiCorp Terraform • Docker • Kubernetes

---

## Objectif du travail

L’objectif de ce travail est de déployer une application sur un cluster Kubernetes en automatisant toutes les étapes.

Cela va du déploiement de l’infrastructure au déploiement de l’application sur le cluster.

Cela permettra de mettre en pratique les différents notions vues dans les modules **IaC – Terraform** et **Conteneurisation avancée** dont vous pourrez vous inspirer pour la réalisation de votre travail.

Le travail contient deux modules, deux notes en seront extraites : une pour chaque module.

---

## Application à déployer

L’application sur laquelle vous aurez à travailler permet de gérer de manière très simpliste des produits.

Elle est développée en PHP et utilise une base de données **MySQL / MariaDB**.

Le dépôt git de l’application est accessible à cette adresse :

👉 https://avalone-fr.com/anthony/gestion-produits

L’application dispose d’un jeu d’essai basique de produits (base de données et images) que vous pourrez intégrer dès la mise en place de l’application.

Quelques instructions pour la faire fonctionner sont présentes sur la fiche du dépôt git.

---

## Conteneurisation de l’application

Vous allez devoir conteneuriser cette application afin de la faire fonctionner avec Docker sur votre poste de travail.

Tenez compte des caractéristiques de celle-ci afin qu’elle fonctionne correctement et qu’elle puisse facilement être mise à jour et exécutée dans des environnements permettant l’exécution de conteneurs.

---

## Déploiement de l’infrastructure

Vous allez déployer l’infrastructure nécessaire pour faire fonctionner cette application.

Pour automatiser au maximum cette étape, vous utiliserez **Terraform** (ou OpenTofu).

Le choix de l’infrastructure sur laquelle réaliser ce déploiement vous est laissé. Il peut s’agir :

- d’un serveur Proxmox (virtuel, physique, autre)
- d’un hyperviseur quelconque
- d’un prestataire Cloud de votre choix (AWS, Azure, GCP…)
- ou d’une autre solution permettant l’automatisation

Cependant, il faut qu’elle soit facilement accessible afin qu’il soit possible de tester votre travail.

Afin de comparer deux solutions, vous déploierez :

- une infrastructure permettant l’exécution de **Docker** et utilisant un **reverse proxy** frontal de votre choix
- un cluster **Kubernetes** composé de **trois nœuds**  
  *(attention à prévoir une solution pour le stockage partagé)*

---

## Déploiement de l’application

Une fois que vos infrastructures (Docker et Kubernetes) seront déployées, vous procéderez au déploiement de l’application sur les deux environnements en prenant en compte les contraintes d’un déploiement en production.

Ce déploiement doit être automatisé au maximum et aboutir à un accès possible par un utilisateur uniquement par des ports haut **HTTP/HTTPS (80 et 443)**.

> ⚠️ **Attention : n’achetez pas un nom de domaine pour l’occasion.**
>
> Utilisez des astuces pour la résolution de nom locale :
>
> - fichier `hosts`
> - serveur DNS local
>
> Si vous disposez d’un nom de domaine public, vous pouvez l’utiliser pour ce travail et déployer un certificat TLS public, mais cela ne sera pas plus valorisé qu’une exécution purement locale avec des certificats invalides.

---

## Mise à jour de l’application

Afin de démontrer la facilité de maintenir et de faire évoluer cette application, vous mettrez en place une version de celle-ci consistant à la faire fonctionner avec une base de données **PostgreSQL**.

Une URL spécifique devra être mise à disposition pour accéder à cette version de l’application sur vos deux infrastructures (Docker et Kubernetes).

Le processus de mise à jour de l’application devra être automatisé au maximum.

---

# Livrables

Votre travail doit se traduire par la remise :

- d’un dépôt incluant tout votre travail pour la partie Terraform, Docker et Kubernetes
- d’un document Markdown contenant le descriptif technique de votre travail ainsi que les instructions pour l’utiliser

Votre travail doit être transmis par mail à l’adresse :

**anthony@avalone-fr.com**

📅 **dimanche 31 mai 2026 à minuit**

---

# Critères évalués

## Partie IaC – Terraform

| Critères | Points |
|---|---:|
| Déploiement de l’infrastructure pour Docker | 7 |
| Déploiement de l’infrastructure pour Kubernetes | 13 |
| **Total** | **20** |

---

## Partie Conteneurisation

| Critères | Points |
|---|---:|
| Conteneurisation de l’application | 3 |
| Déploiement de l’application sur Docker en prod | 6 |
| Déploiement de l’application sur Kubernetes | 7 |
| Mise à jour de l’application | 4 |
| **Total** | **20** |