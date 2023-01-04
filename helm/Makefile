NFS_HOST=192.168.1.100
KUBECTL_CONTEXT=k3s
NAMESPACE=plex

.PHONY: plex
plex:
	helm upgrade plex kube-plex \
	--kube-context $(KUBECTL_CONTEXT) \
	--install \
	--namespace $(NAMESPACE) \
	--repo https://ressu.github.io/kube-plex \
	--set timezone=America/New_York \
	--set kubePlex.enabled=false \
	--set ingress.enabled=true \
	--set ingress.hosts[0]=plex.localdomain \
	--set service.type=NodePort \
	--set service.nodePort=32400 \
	--set persistence.data.claimName=plex-data-data \
	--set persistence.config.claimName=plex-data-config \
	--set claimToken=$(CLAIM_TOKEN)

.PHONY: plex-data
plex-data:
	helm upgrade plex-data charts/plex-data \
	--kube-context $(KUBECTL_CONTEXT) \
	--install \
	--create-namespace \
	--namespace $(NAMESPACE) \
	--set nfs.server=$(NFS_HOST) \
	--set nfs.path=/mnt/data

.PHONY: cert-manager
cert-manager:
	helm upgrade cert-manager cert-manager \
	--kube-context $(KUBECTL_CONTEXT) \
	--install \
	--create-namespace \
	--namespace cert-manager \
	--repo https://charts.jetstack.io \
	--version v1.10.1 \
	--set installCRDs=true

	helm upgrade cert-manager-webhook-namecheap cert-manager-webhook-namecheap \
	--kube-context $(KUBECTL_CONTEXT) \
	--install \
	--namespace cert-manager \
	--repo https://danajp.github.io/cert-manager-webhook-namecheap

	helm upgrade letsencrypt-namecheap-issuer letsencrypt-namecheap-issuer \
	--kube-context $(KUBECTL_CONTEXT) \
	--install \
	--namespace cert-manager \
	--repo https://danajp.github.io/cert-manager-webhook-namecheap \
	--set email=danajp@gmail.com \
	--set secret=namecheap-credentials

.PHONY: argocd
argocd:
	helm upgrade argocd argo-cd \
	--kube-context $(KUBECTL_CONTEXT) \
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
	--set "configs.cm.accounts\.danajp=apiKey\, login" \
	--set "configs.cm.policy\.default=role:readonly" \
	--set "configs.cm.policy\.csv=g\, danajp\, role:admin"
# TODO: automate argo-cd password setup
