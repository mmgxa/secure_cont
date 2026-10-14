resource "aws_eks_cluster" "this" {
  name                      = "${local.name}-cluster"
  version                   = var.kubernetes_version
  role_arn                  = aws_iam_role.cluster.arn
  enabled_cluster_log_types = ["api", "audit", "authenticator"] # will create cloudwatch log groups

  vpc_config {
    subnet_ids              = module.vpc.public_subnets
    endpoint_private_access = true
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
  }

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  upgrade_policy {
    support_type = "STANDARD"
  }

  # We will install the core addons ourselves rather than having EKS install its own copies.
  # This is the recommended approach
  bootstrap_self_managed_addons = false

  tags = var.tags

  # Ensure the cluster IAM role policy is attached before the control plane is
  # created, and that the VPC/subnets exist first.
  depends_on = [
    aws_iam_role_policy_attachment.cluster,
    module.vpc,
  ]
}

resource "aws_eks_addon" "pre" {
  for_each = local.eks_pre_node_group_addons

  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = each.key
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  tags                        = var.tags
}

resource "aws_eks_addon" "post" {
  for_each = local.eks_post_node_group_addons

  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = each.key
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  tags                        = var.tags

  depends_on = [aws_eks_node_group.this]
}
