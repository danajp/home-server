# Home server setup

Consists of:

- Proxmox as hypervisor
- k3s running in an LXC container
- core kubernetes services bootstrapped via helm
- all other kubernetes applications managed by argo cd

## Proxmox

Proxmox is installed manually using the upstream installer on a USB
stick. An existing ZFS pool is mounted at `/mnt/data`.

Further setup, including bootstrapping the k3s container, is done via
make/ansible in the `hypervisor` directory:

```sh-session
$ cd hypervisor
$ make provision
$ make kubeconfig.yaml
```

This results in `hypervisor/kubeconfig.yaml` which is used for
helm/kubectl commands.

## Helm

Core kubernetes services are provisioned via helm. These services include:

- [1password connect](https://developer.1password.com/docs/connect/) - the secrets provider for external-secrets
- [external-secrets](https://external-secrets.io) - manages kubernetes secrets
- [cert-manager](https://cert-manager.io/) - Automatically provisions TLS certs
- [cert-manager-webhook-namecheap](https://github.com/danajp/cert-manager-webhook-namecheap)
- [argo cd](https://argoproj.github.io/cd/) - handles continuous deployment of kubernetes applications

Each core service has a corresponding `make` target to deploy it. For example:

```sh-session
$ cd helm
$ make 1password-connect
```

## Argo CD

All other kubernetes services are deployed via Argo CD. Argo CD
watches the `applications/` directory in this repo at `master` for new
Application resources and deploys them automatically.
