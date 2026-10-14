# Available AZs in the current region (used to place public subnets).
data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

# Current AWS region (used in outputs / kubeconfig command).
data "aws_region" "current" {}

# Current AWS account/identity. Retained for reference; account ID is also
# available directly from the IAM role ARNs created in iam.tf.
data "aws_caller_identity" "current" {}

# Auth token for the helm provider. Depends on the cluster existing, which
# Terraform resolves automatically within the single apply.
data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.this.name
}
