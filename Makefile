ignition.json: config.yaml
	ct -in-file config.yaml -out-file $@ -pretty -strict -platform custom

packer-flatcar-virtualbox.box: vagrant-box.pkr.hcl ignition.json
	packer validate $<
	packer build $<

.PHONY: clean
clean:
	vagrant destroy -f
	rm -f packer-flatcar-virtualbox.box
	rm -rf output-flatcar

.PHONY: up
up: packer-flatcar-virtualbox.box
	vagrant up

.PHONY: ssh
ssh: up
	vagrant ssh
