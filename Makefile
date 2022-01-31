ignition.json:
	ct -in-file config.yaml -out-file $@ -pretty -strict -platform custom

packer-flatcar-virtualbox.box: vagrant-box.pkr.hcl ignition.json
	packer validate $<
	packer build $<
