terraform {
  backend "s3" {
    bucket = "tech-challenge-tfstate"
    key    = "tech-challenge/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.region
}

data "aws_vpc" "existing_vpc" {
  id = var.vpc_id
}

data "aws_subnet" "subnet1" {
  id = var.subnet_ids[0]
}

data "aws_subnet" "subnet2" {
  id = var.subnet_ids[1]
}

data "aws_subnet" "subnet3" {
  id = var.subnet_ids[2]
}

data "aws_subnet" "subnet4" {
  id = var.subnet_ids[3]
}

data "aws_subnet" "subnet5" {
  id = var.subnet_ids[4]
}

data "aws_subnet" "subnet6" {
  id = var.subnet_ids[5]
}

data "aws_iam_role" "lab_role" {
  name = var.iam_role_name
}

# Usando data sources para todos os security groups existentes
data "aws_security_group" "eks_cluster_sg" {
  name   = "${var.project_name}-eks-cluster-sg"
  vpc_id = data.aws_vpc.existing_vpc.id
}

data "aws_security_group" "eks_rds_sg" {
  name   = "${var.project_name}-eks-rds-sg"
  vpc_id = data.aws_vpc.existing_vpc.id
}

data "aws_security_group" "postgres_sg" {
  id = var.postgres_sg_id
}

data "aws_subnet" "subnet1_data" {
  id = data.aws_subnet.subnet1.id
}

data "aws_subnet" "subnet2_data" {
  id = data.aws_subnet.subnet2.id
}

data "aws_subnet" "subnet3_data" {
  id = data.aws_subnet.subnet3.id
}

data "aws_subnet" "subnet4_data" {
  id = data.aws_subnet.subnet4.id
}

data "aws_subnet" "subnet5_data" {
  id = data.aws_subnet.subnet5.id
}

data "aws_subnet" "subnet6_data" {
  id = data.aws_subnet.subnet6.id
}

locals {
  supported_azs = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1f"]

  subnet_az_map = {
    "${data.aws_subnet.subnet1.id}" = data.aws_subnet.subnet1_data.availability_zone
    "${data.aws_subnet.subnet2.id}" = data.aws_subnet.subnet2_data.availability_zone
    "${data.aws_subnet.subnet3.id}" = data.aws_subnet.subnet3_data.availability_zone
    "${data.aws_subnet.subnet4.id}" = data.aws_subnet.subnet4_data.availability_zone
    "${data.aws_subnet.subnet5.id}" = data.aws_subnet.subnet5_data.availability_zone
    "${data.aws_subnet.subnet6.id}" = data.aws_subnet.subnet6_data.availability_zone
  }

  filtered_subnets = [
    for subnet_id, az in local.subnet_az_map :
    subnet_id if contains(local.supported_azs, az)
  ]
}

# Verificar se o cluster EKS já existe
data "aws_eks_clusters" "existing_clusters" {}

locals {
  cluster_exists = contains(data.aws_eks_clusters.existing_clusters.names, var.cluster_name)
}

# Data source para o cluster existente (se existir)
data "aws_eks_cluster" "existing_cluster" {
  count = local.cluster_exists ? 1 : 0
  name  = var.cluster_name
}

# Criar o cluster apenas se não existir
resource "aws_eks_cluster" "tech_eks_cluster" {
  count    = local.cluster_exists ? 0 : 1
  name     = var.cluster_name
  role_arn = data.aws_iam_role.lab_role.arn

  vpc_config {
    subnet_ids         = slice(local.filtered_subnets, 0, min(2, length(local.filtered_subnets)))
    security_group_ids = [data.aws_security_group.eks_cluster_sg.id]
  }

  lifecycle {
    ignore_changes = [
      vpc_config,
      tags,
    ]
  }
}

# Usar o cluster correto dependendo se ele já existe ou foi criado
locals {
  cluster_name = local.cluster_exists ? data.aws_eks_cluster.existing_cluster[0].name : (length(aws_eks_cluster.tech_eks_cluster) > 0 ? aws_eks_cluster.tech_eks_cluster[0].name : var.cluster_name)
  cluster_endpoint = local.cluster_exists ? data.aws_eks_cluster.existing_cluster[0].endpoint : (length(aws_eks_cluster.tech_eks_cluster) > 0 ? aws_eks_cluster.tech_eks_cluster[0].endpoint : "")
}

# Verificar se o node group já existe
data "aws_eks_node_groups" "existing_node_groups" {
  count      = local.cluster_exists ? 1 : 0
  cluster_name = local.cluster_name
}

locals {
  node_group_exists = local.cluster_exists ? contains(try(data.aws_eks_node_groups.existing_node_groups[0].names, []), "${var.project_name}-node-group") : false
}

# Criar o node group apenas se não existir
resource "aws_eks_node_group" "tech_node_group" {
  count           = local.node_group_exists ? 0 : 1
  cluster_name    = local.cluster_name
  node_group_name = "${var.project_name}-node-group"
  node_role_arn   = data.aws_iam_role.lab_role.arn
  subnet_ids      = local.filtered_subnets
  instance_types  = [var.instance_type]

  scaling_config {
    desired_size = var.desired_capacity
    max_size     = var.max_capacity
    min_size     = var.min_capacity
  }

  capacity_type = "ON_DEMAND"

  update_config {
    max_unavailable = 1
  }

  lifecycle {
    ignore_changes = [
      scaling_config,
      tags,
    ]
  }
}