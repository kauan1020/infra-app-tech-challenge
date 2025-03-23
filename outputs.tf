output "eks_cluster_endpoint" {
  description = "The endpoint for the EKS control plane"
  value       = aws_eks_cluster.tech_eks_cluster.endpoint
}

output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.tech_eks_cluster.name
}

output "region" {
  description = "AWS region used for the resources"
  value       = var.region
}

output "kubeconfig_update_command" {
  description = "Command to update kubeconfig for the new cluster"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${aws_eks_cluster.tech_eks_cluster.name}"
}