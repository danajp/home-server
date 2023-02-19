KUBECONFIG=../hypervisor/kubeconfig.yaml
HELM=helm --kubeconfig=$(KUBECONFIG)
KUBECTL=kubectl --kubeconfig=$(KUBECONFIG)

# assert that we're logged in with the 1pass cli
.PHONY: op-logged-in
op-logged-in:
	op whoami

.PHONY: 1password-connect
1password-connect: op-logged-in
	$(HELM) upgrade 1password-connect connect \
	--install \
	--create-namespace \
	--namespace 1password \
	--repo https://1password.github.io/connect-helm-charts \
	--version 1.10.0 \
	--set connect.credentials_base64=$(shell op document get --vault home-server 'home-server Credentials File' | base64 -w0)

.PHONY: external-secrets
external-secrets: op-logged-in
	$(HELM) upgrade external-secrets external-secrets \
	--install \
	--create-namespace \
	--namespace external-secrets \
	--repo https://charts.external-secrets.io \
	--version 0.7.2 \
	--set installCRDs=true

	# use create --dry-run/apply to avoid error when the secret already exists
	$(KUBECTL) create secret generic \
	1password-connect-token \
	--namespace external-secrets \
	--from-literal token=$(shell op item get --vault home-server 'home-server Access Token: external-secrets' --field credential) \
	--dry-run=client \
	-o yaml \
	| kubectl apply -f -

	$(KUBECTL) apply -f 1password-secret-store.yaml

.PHONY: cert-manager
cert-manager: op-logged-in
	$(KUBECTL) apply -f cert-manager-namecheap-external-secret.yaml

	$(HELM) upgrade cert-manager cert-manager \
	--install \
	--create-namespace \
	--namespace cert-manager \
	--repo https://charts.jetstack.io \
	--version v1.10.1 \
	--set installCRDs=true

	$(HELM) upgrade cert-manager-webhook-namecheap cert-manager-webhook-namecheap \
	--install \
	--namespace cert-manager \
	--repo https://danajp.github.io/cert-manager-webhook-namecheap

	$(HELM) upgrade letsencrypt-namecheap-issuer letsencrypt-namecheap-issuer \
	--install \
	--namespace cert-manager \
	--repo https://danajp.github.io/cert-manager-webhook-namecheap \
	--set email=danajp@gmail.com \
	--set secret=namecheap-credentials

# TODO: automate argo-cd password setup
# To finish setup:
# 1. Get the admin pw:
#    kubectl get secret -n argocd  argocd-initial-admin-secret -o json | jq '.data.password | @base64d' -r
# 2. Login as admin with the cli
#    argocd login --username admin
# 3. Change pw for danajp
#    argocd account update-password --account danajp --new-password setecastronomy
.PHONY: argocd
argocd: op-logged-in
	$(HELM) upgrade argocd argo-cd \
	--install \
	--create-namespace \
	--namespace argocd \
	--repo https://argoproj.github.io/argo-helm \
	--set controller.replicas=1 \
	--set server.replicas=1 \
	--set server.ingress.enabled=true \
	--set server.ingress.tls[0].hosts[0]=argo-cd.home.danajp.org \
	--set server.ingress.tls[0].secretName=argocd-server-tls \
	--set server.ingress.hosts[0]=argo-cd.home.danajp.org \
	--set "server.ingress.annotations.cert-manager\.io/cluster-issuer=letsencrypt-prod" \
	--set applicationSet.replicas=1 \
	--set "configs.params.server\.insecure=true" \
	--set dex.enabled=false \
	--set "configs.cm.accounts\.danajp=apiKey\,login" \
	--set "configs.rbac.policy\.default=role:readonly" \
	--set "configs.rbac.policy\.csv=g\,danajp\,role:admin" \
	--set configs.repositories.home-server.type=git \
	--set configs.repositories.home-server.project=default \
	--set configs.repositories.home-server.name=home-server \
	--set configs.repositories.home-server.url=https://github.com/danajp/home-server \
	--set configs.repositories.home-server.username=danajp \
	--set configs.repositories.home-server.password=$(shell op item get github.com --fields label=argo-cd-pat)

	$(HELM) upgrade root-application charts/root-application \
	--install \
	--namespace argocd \
	--set repo.owner=danajp \
	--set repo.name=home-server \
	--set repo.targetRevision=initial-development
