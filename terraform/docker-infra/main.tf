# Récupère automatiquement la dernière AMI Amazon Linux 2023 dans la région choisie
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# Security group : seuls les ports 80, 443 et 22 sont ouverts vers l'extérieur
resource "aws_security_group" "docker_host" {
  name        = "docker-host-sg"
  description = "Trafic autorise pour le serveur Docker"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  # Tout le trafic sortant est autorisé (pull images Docker, git clone, etc.)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "docker-host-sg"
    Project = "gestion-produits"
  }
}

module "docker_host" {
  source = "../modules/ec2"

  ami_id             = data.aws_ami.amazon_linux.id
  instance_type      = "t3.micro"
  key_name           = var.key_name
  security_group_ids = [aws_security_group.docker_host.id]

  user_data = templatefile("${path.module}/scripts/init-docker.sh.tpl", {
    repo_url            = var.repo_url
    db_user             = var.db_user
    db_password         = var.db_password
    db_name             = var.db_name
    mysql_root_password = var.mysql_root_password
    pgsql_user          = var.pgsql_user
    pgsql_password      = var.pgsql_password
    pgsql_db            = var.pgsql_db
  })

  tags = {
    Name    = "docker-host"
    Project = "gestion-produits"
  }
}
