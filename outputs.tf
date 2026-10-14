# =============================================================================
# Networking
# =============================================================================

output "aws_region" {
  value = data.aws_region.current.region
}

output "azs" {
  value = data.aws_availability_zones.available.names
}

output "subnet_ids" {
  value = module.vpc.public_subnets
}

# =============================================================================
# IAM
# =============================================================================

output "iam_cluster_role_name" {
  value = aws_iam_role.cluster.name
}

output "iam_cluster_role_arn" {
  value = aws_iam_role.cluster.arn
}

output "iam_node_role_name" {
  value = aws_iam_role.node.name
}

output "iam_node_role_arn" {
  value = aws_iam_role.node.arn
}

# =============================================================================
# EKS
# =============================================================================

output "cluster_name" {
  description = "Name of the EKS cluster."
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "Kubernetes API server endpoint."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_version" {
  description = "Kubernetes version running on the control plane."
  value       = aws_eks_cluster.this.version
}

output "update_kubeconfig_command" {
  description = "Run this to point kubectl at the new cluster."
  value       = "aws eks update-kubeconfig --name ${aws_eks_cluster.this.name} --profile ${var.aws_profile} --region ${var.aws_region}"
}
