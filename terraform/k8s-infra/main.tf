data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# Security group commun à tous les nœuds du cluster
resource "aws_security_group" "k3s_cluster" {
  name        = "k3s-cluster-sg"
  description = "Trafic autorise pour le cluster k3s"

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

  ingress {
    description = "kubectl (API server k3s)"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  # Tout le trafic entre les nœuds du même security group est autorisé
  # (kubelet, Flannel VXLAN, etc.)
  ingress {
    description = "Trafic intra-cluster"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "k3s-cluster-sg"
    Project = "gestion-produits"
  }
}

# --- Nœud Master ---
module "k3s_master" {
  source = "../modules/ec2"

  ami_id             = data.aws_ami.amazon_linux.id
  instance_type      = "t3.small"
  key_name           = var.key_name
  security_group_ids = [aws_security_group.k3s_cluster.id]

  user_data = templatefile("${path.module}/scripts/init-master.sh.tpl", {
    k3s_token = var.k3s_token
  })

  tags = {
    Name    = "k3s-master"
    Role    = "master"
    Project = "gestion-produits"
  }
}

# --- Nœuds Workers (×2) ---
# Terraform crée les workers APRÈS le master grâce à la dépendance implicite
# sur module.k3s_master.private_ip dans le templatefile
module "k3s_workers" {
  count  = 2
  source = "../modules/ec2"

  ami_id             = data.aws_ami.amazon_linux.id
  instance_type      = "t3.small"
  key_name           = var.key_name
  security_group_ids = [aws_security_group.k3s_cluster.id]

  user_data = templatefile("${path.module}/scripts/init-worker.sh.tpl", {
    k3s_token         = var.k3s_token
    master_private_ip = module.k3s_master.private_ip
  })

  tags = {
    Name    = "k3s-worker-${count.index + 1}"
    Role    = "worker"
    Project = "gestion-produits"
  }
}
