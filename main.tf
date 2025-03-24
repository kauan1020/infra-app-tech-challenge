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

locals {
  supported_azs = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1f"]

  subnet_az_map = {
    "${data.aws_subnet.subnet1.id}" = data.aws_subnet.subnet1.availability_zone
    "${data.aws_subnet.subnet2.id}" = data.aws_subnet.subnet2.availability_zone
    "${data.aws_subnet.subnet3.id}" = data.aws_subnet.subnet3.availability_zone
    "${data.aws_subnet.subnet4.id}" = data.aws_subnet.subnet4.availability_zone
    "${data.aws_subnet.subnet5.id}" = data.aws_subnet.subnet5.availability_zone
    "${data.aws_subnet.subnet6.id}" = data.aws_subnet.subnet6.availability_zone
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

  tags = {
    Environment = "Dev"
    Tech_Challenge = "Fase 3"
    Project     = var.project_name
    ManagedBy   = "Terraform"
    UpdatedAt   = "2025-03-25"
    TestTag     = "TestValue"
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      vpc_config,
    ]
  }
}
