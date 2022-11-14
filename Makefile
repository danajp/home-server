FLATCAR_BASE_IMAGE=flatcar_production_qemu_image.img

$(FLATCAR_BASE_IMAGE): SHELL:=/bin/bash
$(FLATCAR_BASE_IMAGE):
	wget https://beta.release.flatcar-linux.net/amd64-usr/current/flatcar_production_qemu_image.img.bz2{,.sig}
# TODO verify signature of image
#	gpg --verify flatcar_production_qemu_image.img.bz2.sig
	bunzip2 flatcar_production_qemu_image.img.bz2
#	qemu-img resize flatcar_production_qemu_image-libvirt-import.img +5G

.PHONY: apply
apply: $(FLATCAR_BASE_IMAGE) config.ign .terraform
	terraform apply -var "base_image=$(FLATCAR_BASE_IMAGE)"

.PHONY: destroy
destroy: $(FLATCAR_BASE_IMAGE) config.ign .terraform
	terraform destroy -var "base_image=$(FLATCAR_BASE_IMAGE)"

config.ign: config.yaml
	ct -in-file $< -out-file $@ -pretty -strict -platform custom

.terraform:
	terraform init
