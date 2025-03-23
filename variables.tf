variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_id" {
  type    = string
  default = "vpc-05990529b17e1f6b2"
}

variable "subnet_ids" {
  type    = list(string)
  default = [
    "subnet-08dbed1e92dd69532",
    "subnet-01ec3dff60a3e42d6",
    "subnet-0eb850c74a8a2cc68",
    "subnet-015fd3a4050f01494",
    "subnet-0cae5f98952ad6a36",
    "subnet-0098125101b510832"
  ]
}

variable "postgres_sg_id" {
  type    = string
  default = "sg-0c3b3ddc4f9bed8a3"
}

variable "iam_role_name" {
  type    = string
  default = "LabRole"
}

variable "project_name" {
  type    = string
  default = "tech"
}

variable "cluster_name" {
  type    = string
  default = "tech-eks-cluster"
}

variable "instance_type" {
  type    = string
  default = "t3.medium"
}

variable "desired_capacity" {
  type    = number
  default = 2
}

variable "max_capacity" {
  type    = number
  default = 3
}

variable "min_capacity" {
  type    = number
  default = 1
}