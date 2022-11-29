# Makefile for setup proxmox
include .env

# By default, Makefile targets are "file targets" - they are used to build files from other files. Make assumes its target is a file, and this makes writing Makefiles relatively easy:
# In terms of Make, a phony target is simply a target that is always out-of-date, so whenever you ask make <phony_target>, it will run, independent from the state of the file system. Some common make targets that are often phony are: all, install, clean, distclean, TAGS, info, check.
# sudo ssh-keygen -t rsa -f root_rsa
.PHONY: all
all:
	@echo use parameter
	@exit -1

.PHONY: proxmox-add-ssh-key
proxmox-add-ssh-key:
	ssh-copy-id -f -i $(ROOT_SSH_KEY_FILE).pub -o "IdentityFile /root/root.pem" root@$(PVE1_IP)
	ssh-copy-id -f -i $(ROOT_SSH_KEY_FILE).pub -o "IdentityFile /root/root.pem" root@$(PVE2_IP)
	ssh-copy-id -f -i $(ROOT_SSH_KEY_FILE).pub -o "IdentityFile /root/root.pem" root@$(PVE3_IP)


.PHONY: proxmox-add-user
proxmox-add-user:
	ssh -v -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE1_IP) bash -c '"adduser --quiet --disabled-password --shell /bin/bash --home /home/$(USER) --ingroup "sudo" --gecos "User" $(USER); echo "$(USER):$(PASSWD)" | chpasswd"'
	ssh -v -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE2_IP) bash -c '"adduser --quiet --disabled-password --shell /bin/bash --home /home/$(USER) --ingroup "sudo" --gecos "User" $(USER); echo "$(USER):$(PASSWD)" | chpasswd"'
	ssh -v -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE3_IP) bash -c '"adduser --quiet --disabled-password --shell /bin/bash --home /home/$(USER) --ingroup "sudo" --gecos "User" $(USER); echo "$(USER):$(PASSWD)" | chpasswd"'

.PHONY: change-password
change-password:
	ssh -v -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE1_IP) bash -c '"echo "$(USER):$(PASSWD)" | chpasswd"'
	ssh -v -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE2_IP) bash -c '"echo "$(USER):$(PASSWD)" | chpasswd"'
	ssh -v -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE3_IP) bash -c '"echo "$(USER):$(PASSWD)" | chpasswd"'

define UPDATE_TF_USER
pveum role modify TerraformProv -privs \"VM.Allocate VM.Clone VM.Config.CDROM VM.Config.CPU VM.Config.Cloudinit VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Monitor VM.Audit VM.PowerMgmt Datastore.AllocateSpace Datastore.Audit\" \
&& pveum aclmod / -user terraform-prov@pve -role TerraformProv
endef

.PHONY: proxmox-terraform-update
proxmox-terraform-update:
	ssh -v -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE1_IP) bash -c '"$(UPDATE_TF_USER)"'

.PHONY: proxmox-terraform-add-id
proxmox-terraform-add-id:
	ssh -v -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE1_IP) \
	bash -c '"adduser --quiet --disabled-password --shell /bin/bash --home /home/$(USER) --ingroup "sudo" --gecos "User" $(USER); echo "$(USER):$(PASSWD)" | chpasswd"'
	ssh -v -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE2_IP) \
	bash -c '"adduser --quiet --disabled-password --shell /bin/bash --home /home/$(USER) --ingroup "sudo" --gecos "User" $(USER); echo "$(USER):$(PASSWD)" | chpasswd"'
	ssh -v -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE3_IP) \
	bash -c '"adduser --quiet --disabled-password --shell /bin/bash --home /home/$(USER) --ingroup "sudo" --gecos "User" $(USER); echo "$(USER):$(PASSWD)" | chpasswd"'

.PHONY: proxmox-terraform-copy-key
proxmox-terraform-copy-key:
	ssh-copy-id -f -i $(TERRAFORM_SSH_KEY_FILE) -o "IdentityFile /home/$(USER)/$(USER).pem" $(USER)@$(PVE1_IP)
	ssh-copy-id -f -i $(TERRAFORM_SSH_KEY_FILE) -o "IdentityFile /home/$(USER)/$(USER).pem" $(USER)@$(PVE2_IP)
	ssh-copy-id -f -i $(TERRAFORM_SSH_KEY_FILE) -o "IdentityFile /home/$(USER)/$(USER).pem" $(USER)@$(PVE3_IP)


.PHONY: proxmox-copy-net-config
proxmox-copy-net-config:
	scp -i $(TERRAFORM_SSH_KEY_FILE) ./ansible/roles/common/templates/interfaces.j2 $(USER)@$(PVE1_IP):/home/$(USER)/
	scp -i $(TERRAFORM_SSH_KEY_FILE) ./ansible/roles/common/templates/firewall.sh.j2 $(USER)@$(PVE1_IP):/home/$(USER)/
	scp -i $(TERRAFORM_SSH_KEY_FILE) ./ansible/roles/common/templates/interfaces.j2 $(USER)@$(PVE2_IP):/home/$(USER)/
	scp -i $(TERRAFORM_SSH_KEY_FILE) ./ansible/roles/common/templates/firewall.sh.j2 $(USER)@$(PVE2_IP):/home/$(USER)/
	scp -i $(TERRAFORM_SSH_KEY_FILE) ./ansible/roles/common/templates/interfaces.j2 $(USER)@$(PVE3_IP):/home/$(USER)/
	scp -i $(TERRAFORM_SSH_KEY_FILE) ./ansible/roles/common/templates/firewall.sh.j2 $(USER)@$(PVE3_IP):/home/$(USER)/

.PHONY: proxmox-off-pve-apt
proxmox-off-pve-apt:
	ssh -v -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE1_IP) bash -c '"true > /etc/apt/sources.list.d/pve-enterprise.list"'
	ssh -v -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE2_IP) bash -c '"true > /etc/apt/sources.list.d/pve-enterprise.list"'
	ssh -v -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE3_IP) bash -c '"true > /etc/apt/sources.list.d/pve-enterprise.list"'

.PHONY: proxmox-apt-upgrade
proxmox-apt-upgrade:
	ssh -v -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE1_IP) bash -c '"apt-get update && apt-get upgrade -y"'
	ssh -v -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE2_IP) bash -c '"apt-get update && apt-get upgrade -y"'
	ssh -v -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE3_IP) bash -c '"apt-get update && apt-get upgrade -y"'

.PHONY: proxmox-init-ansible
proxmox-init-ansible:
# workaround for error - No module named 'distutils.cmd'
# proxmox's python3.9 has no distutils
# ansible needs python3 and pip3
	ssh -v -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE1_IP) bash -c '"apt-get install -y python3.9-distutils && curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && python3 get-pip.py && pip3 install --ignore-installed ansible"'
	ssh -v -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE2_IP) bash -c '"apt-get install -y python3.9-distutils && curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && python3 get-pip.py && pip3 install --ignore-installed ansible"'
	ssh -v -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE3_IP) bash -c '"apt-get install -y python3.9-distutils && curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && python3 get-pip.py && pip3 install --ignore-installed ansible"'

.PHONY: proxmox-apt-install
proxmox-apt-install:
	ansible-playbook -i ./ansible/tasks/inventory-proxmox.yaml ./ansible/tasks/proxmox-apt-install.yaml -u root --private-key $(ROOT_SSH_KEY_FILE)

.PHONY: proxmox-install-docker
proxmox-install-docker:
	ansible-playbook -i ./ansible/tasks/inventory-proxmox.yaml ./ansible/tasks/proxmox-install-docker.yaml -u root  --private-key $(ROOT_SSH_KEY_FILE)

.PHONY: proxmox-create-group
proxmox-create-group:
	ansible-playbook -i ./ansible/tasks/inventory-proxmox.yaml ./ansible/tasks/proxmox-create-group.yaml -u root  --private-key $(ROOT_SSH_KEY_FILE)

.PHONY: proxmox-install-zerotier
proxmox-install-zerotier:
	ansible-playbook -i ./ansible/tasks/inventory-proxmox.yaml ./ansible/tasks/proxmox-install-zerotier.yaml -u root  --private-key $(ROOT_SSH_KEY_FILE)

.PHONY: reboot
reboot:
	ansible-playbook -i ./ansible/tasks/inventory-proxmox.yaml ./ansible/tasks/reboot.yaml -u root --private-key $(ROOT_SSH_KEY_FILE)

.PHONY: restart-service
restart-service:
	ssh -v -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE1_IP) \
	bash -c '"systemctl restart pvedaemon pveproxy"'
	ssh -v -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE2_IP) \
	bash -c '"systemctl restart pvedaemon pveproxy"'
	ssh -v -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE3_IP) \
	bash -c '"systemctl restart pvedaemon pveproxy"'


.PHONY: proxmox-terraform-del
proxmox-terraform-del:
	ssh -v -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE1_IP) \
	bash -c '"pveum user del terraform-prov@pve && pveum role del TerraformProv"'


define CREATE_TEMPLATE_1
wget http://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img \
&& qm create $(VM_TEMPLATE_ID_1) --memory 2048 --net0 virtio,bridge=vmbr0 \
&& qm importdisk $(VM_TEMPLATE_ID_1) jammy-server-cloudimg-amd64.img local --format qcow2 \
&& qm set $(VM_TEMPLATE_ID_1) --scsihw virtio-scsi-pci --scsi0 local:$(VM_TEMPLATE_ID_1)/vm-$(VM_TEMPLATE_ID_1)-disk-0.qcow2 \
&& qm set $(VM_TEMPLATE_ID_1) --ide2 local:cloudinit \
&& qm set $(VM_TEMPLATE_ID_1) --boot c --bootdisk scsi0 \
&& qm set $(VM_TEMPLATE_ID_1) --serial0 socket --vga serial0 \
&& qm template $(VM_TEMPLATE_ID_1)
endef

define CREATE_TEMPLATE_2
wget http://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img \
&& qm create $(VM_TEMPLATE_ID_2) --memory 2048 --net0 virtio,bridge=vmbr0 \
&& qm importdisk $(VM_TEMPLATE_ID_2) jammy-server-cloudimg-amd64.img local --format qcow2 \
&& qm set $(VM_TEMPLATE_ID_2) --scsihw virtio-scsi-pci --scsi0 local:$(VM_TEMPLATE_ID_2)/vm-$(VM_TEMPLATE_ID_2)-disk-0.qcow2 \
&& qm set $(VM_TEMPLATE_ID_2) --ide2 local:cloudinit \
&& qm set $(VM_TEMPLATE_ID_2) --boot c --bootdisk scsi0 \
&& qm set $(VM_TEMPLATE_ID_2) --serial0 socket --vga serial0 \
&& qm template $(VM_TEMPLATE_ID_2)
endef

define CREATE_TEMPLATE_3
wget http://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img \
&& qm create $(VM_TEMPLATE_ID_3) --memory 2048 --net0 virtio,bridge=vmbr0 \
&& qm importdisk $(VM_TEMPLATE_ID_3) jammy-server-cloudimg-amd64.img local --format qcow2 \
&& qm set $(VM_TEMPLATE_ID_3) --scsihw virtio-scsi-pci --scsi0 local:$(VM_TEMPLATE_ID_3)/vm-$(VM_TEMPLATE_ID_3)-disk-0.qcow2 \
&& qm set $(VM_TEMPLATE_ID_3) --ide2 local:cloudinit \
&& qm set $(VM_TEMPLATE_ID_3) --boot c --bootdisk scsi0 \
&& qm set $(VM_TEMPLATE_ID_3) --serial0 socket --vga serial0 \
&& qm template $(VM_TEMPLATE_ID_3)
endef

define DOWNLOAD_LXD_TEMPLATE
pveam update && pveam download local ubuntu-22.04-standard_22.04-1_amd64.tar.zst
endef

.PHONY: proxmox-set-local
proxmox-set-local:
	ssh -v -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE1_IP) \
	bash -c '"pvesm set local --content backup,images,iso,rootdir,snippets,vztmpl"'
	ssh -v -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE2_IP) \
	bash -c '"pvesm set local --content backup,images,iso,rootdir,snippets,vztmpl"'
	ssh -v -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE3_IP) \
	bash -c '"pvesm set local --content backup,images,iso,rootdir,snippets,vztmpl"'

.PHONY: proxmox-create-template
proxmox-create-template:
	ssh -v -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE1_IP) bash -c '"$(CREATE_TEMPLATE_1)"'
	ssh -v -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE2_IP) bash -c '"$(CREATE_TEMPLATE_2)"'
	ssh -v -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE3_IP) bash -c '"$(CREATE_TEMPLATE_3)"'

.PHONY: proxmox-destroy-template
proxmox-destroy-template:
	ssh -v -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE1_IP) \
	bash -c '"qm destroy 9000"'


.PHONY: proxmox-down-lxd-template
proxmox-down-lxd-template:
	ssh -v -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE1_IP) \
	bash -c '"$(DOWNLOAD_LXD_TEMPLATE)"'

.PHONY: refresh
refresh:
	terraform -chdir=./terraform refresh

.PHONY: upgrade
upgrade:
	terraform -chdir=./terraform init -upgrade

.PHONY: format
format:
	terraform -chdir=./terraform fmt
.PHONY: plan
plan:
	terraform -chdir=./terraform plan

.PHONY: apply
apply:
	terraform -chdir=./terraform apply --auto-approve -lock=false

.PHONY: destroy
destroy:
	terraform -chdir=./terraform destroy

.PHONY: clean
clean:
	rm -rf ./terraform/.terraform/ *.backup *.tfstate
