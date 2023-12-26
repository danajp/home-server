SHELL := /bin/bash
KUBECONFIG=hypervisor/kubeconfig.yaml
HELM=helm --kubeconfig=$(KUBECONFIG)
KUBECTL=kubectl --kubeconfig=$(KUBECONFIG)

# assert that we're logged in with the 1pass cli
.PHONY: op-logged-in
op-logged-in:
	op whoami

.PHONY: 1password-connect
1password-connect: op-logged-in
	kustomize build --enable-helm kustomizations/1password-connect | $(KUBECTL) apply -f -
	# use create --dry-run/apply to avoid error when the secret already exists
	$(KUBECTL) create secret generic -n 1password op-credentials \
		--from-file 1password-credentials.json=<(op document get --vault home-server 'home-server Credentials File') \
		--dry-run=client \
		-o yaml \
	| $(KUBECTL) apply -f -

.PHONY: external-secrets
external-secrets: op-logged-in
	kustomize build --enable-helm kustomizations/external-secrets | $(KUBECTL) apply -f -
	# use create --dry-run/apply to avoid error when the secret already exists
	$(KUBECTL) create secret generic -n external-secrets 1password-connect-token \
		--from-file token=<(op item get --vault home-server 'home-server Access Token: external-secrets' --field credential) \
		--dry-run=client \
		-o yaml \
	| $(KUBECTL) apply -f -
