module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.7.3"

  name = local.name
  cidr = var.vpc_cidr
  azs  = local.azs

  public_subnets          = slice(var.public_subnet_cidrs, 0, length(local.azs))
  map_public_ip_on_launch = true
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  tags = var.tags
}
