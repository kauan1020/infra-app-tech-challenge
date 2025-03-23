variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
  default     = "vpc-05990529b17e1f6b2"
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
  default     = [
    "subnet-08dbed1e92dd69532",
    "subnet-01ec3dff60a3e42d6",
    "subnet-0eb850c74a8a2cc68",
    "subnet-015fd3a4050f01494",
    "subnet-0cae5f98952ad6a36",
    "subnet-0098125101b510832"
  ]
}

variable "postgres_sg_id" {
  description = "Security group ID of the PostgreSQL RDS"
  type        = string
  default     = "sg-0c3b3ddc4f9bed8a3"
}

variable "iam_role_name" {
  description = "Name of the IAM role for EKS"
  type        = string
  default     = "LabRole"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "tech"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "tech-eks-cluster"
}

variable "instance_type" {
  description = "Instance type for the EKS worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "desired_capacity" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 3
}

variable "min_capacity" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}