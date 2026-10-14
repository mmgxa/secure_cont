module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "21.29.0"

  cluster_name = aws_eks_cluster.this.name

  create_node_iam_role = false
  node_iam_role_arn    = aws_iam_role.node.arn

  create_pod_identity_association = true

  # since we will only be using on-demand nodes for karpenter
  enable_spot_termination = false

  # Since the node group role will already have an access entry
  create_access_entry = false

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }

  # The managed node group (and its role access entry) must exist first.
  depends_on = [aws_eks_node_group.this]
}

resource "helm_release" "karpenter" {
  name             = "karpenter"
  repository       = "oci://public.ecr.aws/karpenter"
  chart            = "karpenter"
  version          = "1.15.0"
  namespace        = "kube-system"
  create_namespace = false

  set = [
    # EKS Cluster Name
    {
      name  = "settings.clusterName"
      value = aws_eks_cluster.this.name
    },
    # EKS Cluster Endpoint
    {
      name  = "settings.clusterEndpoint"
      value = aws_eks_cluster.this.endpoint
    },
    # This is the only required one
    {
      name  = "serviceAccount.name"
      value = "karpenter"
    },
    # Karpenter ServiceAccount
    {
      name  = "serviceAccount.create"
      value = "true"
    },
    # again, for on-demand instances
    {
      name  = "webhook.enabled"
      value = "false"
    }
  ]

  # Very Important: Ensure IAM Role + Pod Identity are created BEFORE Helm deploys Karpenter.
  # These resources live inside module.karpenter, so depend on the module itself.
  # Also ensure core addons (coredns, pod-identity-agent) are present.
  depends_on = [
    module.karpenter,
    aws_eks_addon.post,
  ]
}

# Tag each public subnet so Karpenter's subnetSelectorTerms matches it.
resource "aws_ec2_tag" "karpenter_subnet_discovery" {
  for_each = toset(module.vpc.public_subnets)

  resource_id = each.value
  key         = "karpenter.sh/discovery"
  value       = aws_eks_cluster.this.name
}

# Tag the cluster security group so securityGroupSelectorTerms matches it.
resource "aws_ec2_tag" "karpenter_sg_discovery" {
  resource_id = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
  key         = "karpenter.sh/discovery"
  value       = aws_eks_cluster.this.name
}
