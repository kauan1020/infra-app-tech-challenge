output "eks_cluster_endpoint" {
  description = "The endpoint for the EKS control plane"
  value       = local.cluster_endpoint
}

output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = local.cluster_name
}

output "region" {
  description = "AWS region used for the resources"
  value       = var.region
}

output "kubeconfig_update_command" {
  description = "Command to update kubeconfig for the new cluster"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${local.cluster_name}"
}