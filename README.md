# Secure Containers using Kata Containers

This repo help to deploy Kata Containers that provides VM level isolation even on non-metal instances. The [{c/m/r}{7/8}i and other similar instances support nested virtualization](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/amazon-ec2-nested-virtualization.html#nested-virtualization-considerations).


## Deployment
This provides a single Terraform root module that provisions the full stack in one `terraform apply`:

- **VPC** with public subnets
- **IAM roles** for the EKS cluster and worker nodes
- **EKS cluster** + core addons (vpc-cni, kube-proxy, coredns, pod-identity-agent, metrics-server)
- **Managed node group** (Spot)
- **Karpenter** (module + Helm release) with subnet/security-group discovery tags

Kata Containers and the Karpenter `EC2NodeClass`/`NodePool` are applied as a post-step
via `kubectl`/`helm` (see the Makefile and `kc_node.yaml`).

## Requirements

- Terraform >= 1.5.0
- AWS CLI configured with a profile
- `kubectl`, `helm`, `jq`

## Usage

```bash
# 1. Provision all AWS infrastructure (edit region/profile in the Makefile as needed)
terraform init
make deploy

# 2. Point kubectl at the cluster
#    (run the command printed by the `update_kubeconfig_command` output)
aws eks update-kubeconfig --name k8s-selfmanaged-cluster --profile <profile> --region <region>

# 3. Apply the Karpenter EC2NodeClass + NodePool for nested-virt nodes
kubectl apply -f kc_node.yaml

# 4. Install Kata Containers
make kata

# 5. (optional) Smoke-test the runtimes
kubectl apply -f tests/test-kata-pod.yaml      # QEMU
kubectl apply -f tests/test-kata-fc-pod.yaml   # Firecracker
```

## Teardown

```bash
make cleanup
```

## Configuration

Common variables (see `variables.tf` for the full list and defaults):

| Variable | Default | Description |
|----------|---------|-------------|
| `aws_region` | — (required) | AWS region |
| `aws_profile` | — (required) | AWS CLI profile |
| `name` | `k8s-selfmanaged` | Base name for all resources |
| `kubernetes_version` | `1.37` | EKS control-plane version |
| `vpc_cidr` | `12.0.0.0/16` | VPC CIDR |
| `node_instance_types` | `t3*/t3a*` | Managed node group instance types |

> **Note:** `kc_node.yaml` hardcodes `k8s-selfmanaged-*` names. If you change `name`,
> update `kc_node.yaml` to match.

## Layout

```
deploy/
├── versions.tf / providers.tf / backend.tf
├── variables.tf / locals.tf / data.tf / outputs.tf
├── vpc.tf / iam.tf / eks.tf / node_group.tf / karpenter.tf
├── Makefile
├── kc_node.yaml / kata-deploy-values.yaml
└── tests/
```
