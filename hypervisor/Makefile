HYPERVISOR_IP=192.168.1.100

ifneq ($(strip $(TAGS)),)
override TAGS := --tags $(TAGS)
endif

.PHONY: provision
provision:
	ansible-playbook provision.yaml \
	-i $(HYPERVISOR_IP), \
	--user root \
	-e hypervisor_ip=$(HYPERVISOR_IP) \
	$(TAGS) \
	-vv

.k3s-ip:
	ssh root@192.168.1.100 pct exec 104 -- hostname -I | xargs -n1 | grep '192\.168\.' > $@

kubeconfig.yaml: .k3s-ip
	ssh root@$(HYPERVISOR_IP) pct exec 104 -- cat /etc/rancher/k3s/k3s.yaml | sed "s|127.0.0.1|$(shell cat .k3s-ip)|g" > $@
	chmod 600 $@

.PHONY: install-ansible-collections
install-ansible-collections:
	ansible-galaxy collection install ansible.posix
