variable "ami_id" {
  description = "AMI ID pour l'instance"
  type        = string
}

variable "instance_type" {
  description = "Type d'instance EC2 (ex: t3.micro, t3.small)"
  type        = string
}

variable "key_name" {
  description = "Nom de la paire de clés SSH dans AWS"
  type        = string
}

variable "security_group_ids" {
  description = "Liste des IDs de security groups à associer"
  type        = list(string)
}

variable "user_data" {
  description = "Script shell exécuté au premier démarrage de l'instance"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags AWS appliqués à l'instance"
  type        = map(string)
  default     = {}
}
