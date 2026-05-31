variable "aws_region" {
  description = "Région AWS cible"
  type        = string
  default     = "eu-west-3"
}

variable "key_name" {
  description = "Nom de la paire de clés SSH existante dans AWS"
  type        = string
}

variable "my_ip_cidr" {
  description = "Ton IP publique en CIDR pour SSH et accès kubectl (ex: 1.2.3.4/32)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "k3s_token" {
  description = "Token partagé entre tous les nœuds du cluster k3s (chaîne aléatoire longue)"
  type        = string
  sensitive   = true
}
