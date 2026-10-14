locals {
  name = var.name

  # Pick the first 3 AZs available in the region.
  azs = slice(data.aws_availability_zones.available.names, 0, 3)

  # Core EKS addons installed before the node group comes up.
  eks_pre_node_group_addons = {
    "vpc-cni"    = {}
    "kube-proxy" = {}
  }

  # Addons that need running nodes, installed after the node group.
  eks_post_node_group_addons = {
    "coredns"                = {}
    "eks-pod-identity-agent" = {}
    "metrics-server"         = {}
  }

  ssh_key_name = var.aws_profile # it is a coincidence that the profile name is the same as the key name
}
