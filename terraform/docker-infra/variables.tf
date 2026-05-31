variable "aws_region" {
  description = "Région AWS cible"
  type        = string
  default     = "eu-west-3"
}

variable "key_name" {
  description = "Nom de la paire de clés SSH existante dans AWS (créée manuellement dans EC2 > Key Pairs)"
  type        = string
}

variable "my_ip_cidr" {
  description = "Ton IP publique en notation CIDR pour restreindre l'accès SSH (ex: 1.2.3.4/32). Mettre 0.0.0.0/0 pour tout ouvrir (déconseillé)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "repo_url" {
  description = "URL du dépôt Git à cloner sur le serveur (doit être accessible depuis EC2)"
  type        = string
}

variable "db_user" {
  description = "Utilisateur de la base de données applicative"
  type        = string
  default     = "app"
}

variable "db_password" {
  description = "Mot de passe de l'utilisateur applicatif"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Nom de la base de données"
  type        = string
  default     = "gestion_produits"
}

variable "mysql_root_password" {
  description = "Mot de passe root MySQL"
  type        = string
  sensitive   = true
}

variable "pgsql_user" {
  description = "Utilisateur PostgreSQL applicatif"
  type        = string
  default     = "app_pgsql"
}

variable "pgsql_password" {
  description = "Mot de passe PostgreSQL applicatif"
  type        = string
  sensitive   = true
}

variable "pgsql_db" {
  description = "Nom de la base PostgreSQL"
  type        = string
  default     = "gestion_produits"
}
