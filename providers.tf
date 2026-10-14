# tags will be applied to all resources this configuration creates
provider "aws" {
  default_tags {
    tags = var.tags
  }
  profile = var.aws_profile
  region  = var.aws_region
}

# HELM Provider
# Wired directly to the EKS cluster resource (not a data source) so that in a
# single `terraform apply` the provider is configured only after the cluster
# exists. Auth token comes from aws_eks_cluster_auth (see data.tf).
provider "helm" {
  kubernetes = {
    host                   = aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}
