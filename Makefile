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
	$(KUBECTL) create secret generic -n 1password op-credentials --from-file 1password-credentials.json=<(op document get --vault home-server 'home-server Credentials File')
