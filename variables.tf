# =============================================================================
# AWS Related
# =============================================================================

variable "aws_profile" {
  type = string
}

variable "aws_region" {
  type = string
}

# =============================================================================
# Networking (VPC)
# =============================================================================

variable "vpc_cidr" {
  description = "The CIDR range for the VPC. This should be a valid private (RFC 1918) CIDR range."
  type        = string
  default     = "12.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets within the VPC. The third subnet is used only if the region has more than 2 AZs."
  type        = list(string)
  default     = ["12.0.1.0/24", "12.0.2.0/24", "12.0.3.0/24"]
}

variable "enable_outbound_internet_access" {
  description = "Whether to deploy a NAT gateway to enable access from private subnets to the internet."
  type        = bool
  default     = true
}

# =============================================================================
# EKS Control Plane
# =============================================================================

variable "kubernetes_version" {
  description = "Kubernetes minor version for the control plane and managed addons."
  type        = string
  default     = "1.37"
}

variable "endpoint_public_access" {
  description = "Expose the Kubernetes API endpoint publicly so kubectl can reach from outside the VPC."
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = "CIDRs allowed to reach the public API endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# =============================================================================
# Managed Node Group
# =============================================================================

variable "node_instance_types" {
  description = "Instance types for the Spot managed node group."
  type        = list(string)
  default     = ["t3.medium", "t3a.medium", "t3.large", "t3a.large"]
}

variable "node_desired_size" {
  description = "Desired number of nodes."
  type        = number
  default     = 2
}

variable "node_minimum_size" {
  description = "Minimum number of nodes."
  type        = number
  default     = 1
}

variable "node_maximum_size" {
  description = "Maximum number of nodes."
  type        = number
  default     = 3
}

# =============================================================================
# Shared
# =============================================================================

variable "tags" {
  description = "Tags applied to all resources this configuration creates."
  type        = map(string)
  default = {
    Description = "eks-selfmanaged"
    ManagedBy   = "terraform"
  }
}

# Base name used to derive resource names across the stack:
#   VPC            -> <name>
#   cluster role   -> <name>-clusterrole
#   node role      -> <name>-noderole
#   EKS cluster    -> <name>-cluster
#   node group     -> <name>-nodegroup
# NOTE: kc_node.yaml hardcodes "k8s-selfmanaged-*" names, so keep this default
# in sync with that file if you change it.
variable "name" {
  type    = string
  default = "k8s-selfmanaged"
}
