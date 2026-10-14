resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${local.name}-nodegroup"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = module.vpc.public_subnets

  # Spot instances and configuration
  capacity_type  = "SPOT"
  instance_types = var.node_instance_types

  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_maximum_size
    min_size     = var.node_minimum_size
  }

  update_config {
    max_unavailable = 1
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  tags = var.tags

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.node, # node role policies must exist first
    aws_eks_addon.pre,                   # pre-node-group addons (vpc-cni, kube-proxy, etc.)
  ]
}
