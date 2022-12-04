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
	ssh-copy-id -f -i $(ROOT_SSH_KEY_FILE) -o "IdentityFile /root/root.pem" root@$(PVE1_IP)
	ssh-copy-id -f -i $(ROOT_SSH_KEY_FILE) -o "IdentityFile /root/root.pem" root@$(PVE2_IP)
	ssh-copy-id -f -i $(ROOT_SSH_KEY_FILE) -o "IdentityFile /root/root.pem" root@$(PVE3_IP)


.PHONY: proxmox-add-user
proxmox-add-user:
	ssh -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE1_IP) bash -c '"adduser --quiet --disabled-password --shell /bin/bash --home /home/$(USER) --ingroup "sudo" --gecos "User" $(USER); echo "$(USER):$(PASSWD)" | chpasswd"'
	ssh -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE2_IP) bash -c '"adduser --quiet --disabled-password --shell /bin/bash --home /home/$(USER) --ingroup "sudo" --gecos "User" $(USER); echo "$(USER):$(PASSWD)" | chpasswd"'
	ssh -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE3_IP) bash -c '"adduser --quiet --disabled-password --shell /bin/bash --home /home/$(USER) --ingroup "sudo" --gecos "User" $(USER); echo "$(USER):$(PASSWD)" | chpasswd"'

.PHONY: change-password
change-password:
	ssh -v -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE1_IP) bash -c '"echo "$(USER):$(PASSWD)" | chpasswd"'
	ssh -v -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE2_IP) bash -c '"echo "$(USER):$(PASSWD)" | chpasswd"'
	ssh -v -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE3_IP) bash -c '"echo "$(USER):$(PASSWD)" | chpasswd"'

define UPDATE_TF_USER
pveum role modify TerraformProv -privs \"VM.Allocate VM.Console VM.Clone VM.Config.CDROM VM.Config.CPU VM.Config.Cloudinit VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Monitor VM.Audit VM.PowerMgmt Pool.Allocate Datastore.AllocateSpace Datastore.Audit\" \
&& pveum aclmod / -user terraform-prov@pve -role TerraformProv
endef

.PHONY: proxmox-terraform-update
proxmox-terraform-update:
	ssh -v -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE1_IP) bash -c '"$(UPDATE_TF_USER)"'

.PHONY: proxmox-terraform-add-id
proxmox-terraform-add-id:
	ssh-i $(ROOT_SSH_KEY_FILE) -t root@$(PVE1_IP) \
	bash -c '"adduser --quiet --disabled-password --shell /bin/bash --home /home/$(USER) --ingroup "sudo" --gecos "User" $(USER); echo "$(USER):$(PASSWD)" | chpasswd"'
	ssh-i $(ROOT_SSH_KEY_FILE) -t root@$(PVE2_IP) \
	bash -c '"adduser --quiet --disabled-password --shell /bin/bash --home /home/$(USER) --ingroup "sudo" --gecos "User" $(USER); echo "$(USER):$(PASSWD)" | chpasswd"'
	ssh-i $(ROOT_SSH_KEY_FILE) -t root@$(PVE3_IP) \
	bash -c '"adduser --quiet --disabled-password --shell /bin/bash --home /home/$(USER) --ingroup "sudo" --gecos "User" $(USER); echo "$(USER):$(PASSWD)" | chpasswd"'

.PHONY: proxmox-terraform-copy-key
proxmox-terraform-copy-key:
	ssh-copy-id -f -i $(TERRAFORM_SSH_KEY_FILE) -o "IdentityFile /home/$(USER)/$(USER).pem" $(USER)@$(PVE1_IP)
	ssh-copy-id -f -i $(TERRAFORM_SSH_KEY_FILE) -o "IdentityFile /home/$(USER)/$(USER).pem" $(USER)@$(PVE2_IP)
	ssh-copy-id -f -i $(TERRAFORM_SSH_KEY_FILE) -o "IdentityFile /home/$(USER)/$(USER).pem" $(USER)@$(PVE3_IP)

.PHONY: proxmox-vm-copy-key
proxmox-vm-copy-key:
	ssh-copy-id -f -i $(TERRAFORM_SSH_KEY_FILE) -o "IdentityFile /home/$(USER)/$(USER).pem" $(USER)@$10.10.10.111
	ssh-copy-id -f -i $(TERRAFORM_SSH_KEY_FILE) -o "IdentityFile /home/$(USER)/$(USER).pem" $(USER)@$10.10.10.112
	ssh-copy-id -f -i $(TERRAFORM_SSH_KEY_FILE) -o "IdentityFile /home/$(USER)/$(USER).pem" $(USER)@$10.10.10.113
	ssh-copy-id -f -i $(TERRAFORM_SSH_KEY_FILE) -o "IdentityFile /home/$(USER)/$(USER).pem" $(USER)@$10.10.10.121
	ssh-copy-id -f -i $(TERRAFORM_SSH_KEY_FILE) -o "IdentityFile /home/$(USER)/$(USER).pem" $(USER)@$10.10.10.122
	ssh-copy-id -f -i $(TERRAFORM_SSH_KEY_FILE) -o "IdentityFile /home/$(USER)/$(USER).pem" $(USER)@$10.10.10.123

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
	ssh -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE1_IP) bash -c '"true > /etc/apt/sources.list.d/pve-enterprise.list"'
	ssh -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE2_IP) bash -c '"true > /etc/apt/sources.list.d/pve-enterprise.list"'
	ssh -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE3_IP) bash -c '"true > /etc/apt/sources.list.d/pve-enterprise.list"'

.PHONY: proxmox-apt-upgrade
proxmox-apt-upgrade:
	ssh -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE1_IP) bash -c '"apt-get update && apt-get upgrade -y"'
	ssh -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE2_IP) bash -c '"apt-get update && apt-get upgrade -y"'
	ssh -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE3_IP) bash -c '"apt-get update && apt-get upgrade -y"'

.PHONY: proxmox-init-ansible
proxmox-init-ansible:
# workaround for error - No module named 'distutils.cmd'
# proxmox's python3.9 has no distutils
# ansible needs python3 and pip3
	ssh -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE1_IP) bash -c '"apt-get install -y python3.9-distutils && curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && python3 get-pip.py && pip3 install --ignore-installed ansible"'
	ssh -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE2_IP) bash -c '"apt-get install -y python3.9-distutils && curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && python3 get-pip.py && pip3 install --ignore-installed ansible"'
	ssh -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE3_IP) bash -c '"apt-get install -y python3.9-distutils && curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && python3 get-pip.py && pip3 install --ignore-installed ansible"'

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
	ssh -v -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE1_IP) bash -c '"reboot"'
	ssh -v -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE2_IP) bash -c '"reboot"'
	ssh -v -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE3_IP) bash -c '"reboot"'
	# ansible-playbook -i ./ansible/tasks/inventory-proxmox.yaml ./ansible/tasks/reboot.yaml -u root --private-key $(ROOT_SSH_KEY_FILE)

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



define CREATE_CLOUD_INIT
qm destroy $(VM_ID) --destroy-unreferenced-disks --purge true \
;virt-customize -v -a $(CI_IMG) --update \
&& virt-customize -a $(CI_IMG) \
--install qemu-guest-agent,net-tools,vim,bash-completion,wget,curl,telnet,unzip \
&& virt-customize -a $(CI_IMG) \
--timezone "Asia/Seoul" \
&& qm create $(VM_ID) --memory 2048 --net0 virtio,bridge=vmbr0 \
&& qm importdisk $(VM_ID) $(CI_IMG) $(STORAGE_POOL) --format qcow2\
&& qm set $(VM_ID) --scsihw virtio-scsi-pci --scsi0 $(STORAGE_POOL):$(VM_ID)/vm-$(VM_ID)-disk-0.qcow2 \
&& qm set $(VM_ID) --agent enabled=1,fstrim_cloned_disks=1 \
&& qm set $(VM_ID) --name $(VM_NAME) \
&& qm set $(VM_ID) --ide2 $(STORAGE_POOL):cloudinit \
&& qm set $(VM_ID) --boot c --bootdisk scsi0 \
&& qm set $(VM_ID) --serial0 socket --vga serial0 \
&& qm template $(VM_ID)
endef

define DOWNLOAD_LXD_TEMPLATE
pveam update && pveam download local ubuntu-22.04-standard_22.04-1_amd64.tar.zst
endef

.PHONY: proxmox-set-local
proxmox-set-local:
	ssh -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE1_IP) \
	bash -c '"pvesm set local --content backup,images,iso,rootdir,snippets,vztmpl"'
	ssh -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE2_IP) \
	bash -c '"pvesm set local --content backup,images,iso,rootdir,snippets,vztmpl"'
	ssh -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE3_IP) \
	bash -c '"pvesm set local --content backup,images,iso,rootdir,snippets,vztmpl"'

define WGET_CI_IMAGE
rm -rf /root/$(CI_IMG).* \
;wget http://cloud-images.ubuntu.com/jammy/current/$(CI_IMG)
endef

.PHONY: proxmox-down-ci-template
proxmox-down-ci-template:
	# ssh -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE1_IP) bash -c '"$(WGET_CI_IMAGE)"'
	ssh -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE1_2P) bash -c '"$(WGET_CI_IMAGE)"'
	# ssh -i $(ROOT_SSH_KEY_FILE) -t root@proxmox-create-template$(PVE1_3P) bash -c '"$(WGET_CI_IMAGE)"'

.PHONY: proxmox-create-ci
proxmox-create-ci:
	## local -> pve: id_rsa, root_rsa, .env, *.sh
	## pve -> template: id_rsa, root_rsa, .env, *virt.sh
	cp -f pve1.env .env && scp -i $(ROOT_SSH_KEY_FILE) ./*.sh ./.env  ./terraform/*rsa ./terraform/*rsa.pub  root@$(PVE1_IP):/root/
	cp -f pve1.env .env && scp -i $(ROOT_SSH_KEY_FILE) ./*.sh ./.env  ./terraform/*rsa ./terraform/*rsa.pub  root@$(PVE2_IP):/root/
	cp -f pve1.env .env && scp -i $(ROOT_SSH_KEY_FILE) ./*.sh ./.env  ./terraform/*rsa ./terraform/*rsa.pub  root@$(PVE3_IP):/root/

.PHONY: proxmox-create-template
proxmox-create-template:
	cp -f pve1.env .env
	ssh -i $(ROOT_SSH_KEY_FILE) -t  root@$(PVE1_IP) bash -c '"rm -rf /root/*.sh /root/.env"'
	scp -i $(ROOT_SSH_KEY_FILE) ./*.sh ./.env  ./terraform/*rsa ./terraform/*rsa.pub  root@$(PVE1_IP):/root/
	ssh -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE1_IP) bash -c '"/root/pve-init-cloudinit.sh"'
	ssh -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE1_IP) bash -c '"/root/pve-create-template.sh"'
	cp -f pve2.env .env
	ssh -i $(ROOT_SSH_KEY_FILE) -t  root@$(PVE2_IP) bash -c '"rm -rf /root/*.sh /root/.env"'
	scp -i $(ROOT_SSH_KEY_FILE) ./*.sh ./.env  ./terraform/*rsa ./terraform/*rsa.pub  root@$(PVE2_IP):/root/
	ssh -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE2_IP) bash -c '"/root/pve-init-cloudinit.sh"'
	ssh -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE2_IP) bash -c '"/root/pve-create-template.sh"'
	cp -f pve3.env .env
	ssh -i $(ROOT_SSH_KEY_FILE) -t  root@$(PVE3_IP) bash -c '"rm -rf /root/*.sh /root/.env"'
	scp -i $(ROOT_SSH_KEY_FILE) ./*.sh ./.env  ./terraform/*rsa ./terraform/*rsa.pub  root@$(PVE3_IP):/root/
	ssh -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE3_IP) bash -c '"/root/pve-init-cloudinit.sh"'
	ssh -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE3_IP) bash -c '"/root/pve-create-template.sh"'

.PHONY: proxmox-destroy-template
proxmox-destroy-template:
	# ssh -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE1_IP) bash -c '"qm destroy 9001 && rm -rf /var/lib/vz/images/9001"'
	ssh -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE2_IP) bash -c '"qm destroy 9002 && rm -rf /var/lib/vz/images/9002"'
	ssh -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE3_IP) bash -c '"qm destroy 9003 && rm -rf /var/lib/vz/i mages/9003"'


.PHONY: proxmox-destroy-all
proxmox-destroy-all:
	ssh -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE1_IP) bash -c '"qm destroy --destroy-unreferenced-disks --purge true 9001 "'
	ssh -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE2_IP) bash -c '"qm destroy --destroy-unreferenced-disks --purge true 9002 "'
	ssh -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE3_IP) bash -c '"qm destroy --destroy-unreferenced-disks --purge true 9003 "'

.PHONY: proxmox-add-net1
proxmox-add-net1:
	ssh -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE1_IP) bash -c '"qm set 2001 -net1 virtio,bridge=vmbr0 && qm set 3001 -net1 virtio,bridge=vmbr0 "'
	ssh -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE2_IP) bash -c '"qm set 2002 -net1 virtio,bridge=vmbr0 && qm set 3002 -net1 virtio,bridge=vmbr0 "'
	ssh -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE3_IP) bash -c '"qm set 2003 -net1 virtio,bridge=vmbr0 && qm set 3003 -net1 virtio,bridge=vmbr0 "'

.PHONY: proxmox-down-lxd-template
proxmox-down-lxd-template:
	ssh -v -i $(ROOT_SSH_KEY_FILE) -t root@$(PVE1_IP) bash -c '"$(DOWNLOAD_LXD_TEMPLATE)"'

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
	rm -rf ./terraform/.terraform/ ./terraform/*.backup ./terraform/*.tfstate

.PHONY: ansible
ansible:
	cd ansible && ansible-playbook -v -i inventories/hosts.ini kubernetes.yml
