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

resource "aws_security_group_rule" "eks_to_postgres_sg" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = data.aws_security_group.eks_cluster_sg.id
  security_group_id        = data.aws_security_group.postgres_sg.id
  description              = "Allow PostgreSQL access from EKS cluster"

  lifecycle {
    create_before_destroy = true
  }
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

resource "aws_eks_cluster" "tech_eks_cluster" {
  name     = var.cluster_name
  role_arn = data.aws_iam_role.lab_role.arn

  vpc_config {
    subnet_ids         = slice(local.filtered_subnets, 0, min(2, length(local.filtered_subnets)))
    security_group_ids = [data.aws_security_group.eks_cluster_sg.id]
  }

  lifecycle {
    ignore_changes = [
      vpc_config.0.subnet_ids,
      tags,
    ]
    create_before_destroy = true
  }
}

resource "aws_eks_node_group" "tech_node_group" {
  cluster_name    = aws_eks_cluster.tech_eks_cluster.name
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
      scaling_config.0.desired_size,
      tags,
    ]
    create_before_destroy = true
  }

  depends_on = [
    aws_eks_cluster.tech_eks_cluster
  ]
}