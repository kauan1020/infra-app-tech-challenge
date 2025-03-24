output "eks_cluster_name" {
  value = aws_eks_cluster.tech_eks_cluster.name
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.tech_eks_cluster.endpoint
}

output "region" {
  value = var.region
}

output "kubeconfig_update_command" {
  value = "aws eks update-kubeconfig --region ${var.region} --name ${aws_eks_cluster.tech_eks_cluster.name}"
}

output "cluster_endpoint" {
  value       = aws_eks_cluster.tech_eks_cluster.endpoint
  description = "Endpoint for the Kubernetes API server"
}