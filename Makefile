.PHONY: deploy kata cleanup

# Single apply: provisions VPC, IAM roles, EKS cluster, managed node group,
# and Karpenter (module + helm release) in one shot.
deploy:
	terraform apply -var="aws_region=sa-east-1" -var="aws_profile=default"

# Install Kata Containers via helm (run after `make deploy` and after
# applying kc_node.yaml for the Karpenter EC2NodeClass/NodePool).
kata:
	kubectl create namespace kata-system
	KATA_VERSION=$$(curl -sSL https://api.github.com/repos/kata-containers/kata-containers/releases/latest | jq -r .tag_name) && \
	echo "Installing Kata Containers $${KATA_VERSION}" && \
	helm install kata-deploy \
	  oci://ghcr.io/kata-containers/kata-deploy-charts/kata-deploy \
	  --version "$${KATA_VERSION}" \
	  -f kata-deploy-values.yaml \
	  --namespace kata-system \
	  --wait --timeout 600s

# cleanup.
cleanup:
	helm uninstall kata-deploy -n kata-system
	kubectl delete -f kc_node.yaml  --ignore-not-found
	terraform destroy -var="aws_region=sa-east-1" -var="aws_profile=default"
