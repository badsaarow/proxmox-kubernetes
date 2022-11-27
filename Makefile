# Makefile for setup proxmox

## local ip - $(PVE1_IP)
# PVE1_IP=hci.ext1.gaamtech.kro.kr
# PVE2_IP=hci.ext2.gaamtech.kro.kr
# PVE3_IP=hci.ext3.gaamtech.kro.kr

PVE1_IP=hci.int1.gaamtech.kro.kr
PVE2_IP=hci.int2.gaamtech.kro.kr
PVE3_IP=hci.int3.gaamtech.kro.kr

USER=terraform-prov
PASSWD="gaam123$$%"

# By default, Makefile targets are "file targets" - they are used to build files from other files. Make assumes its target is a file, and this makes writing Makefiles relatively easy:
# In terms of Make, a phony target is simply a target that is always out-of-date, so whenever you ask make <phony_target>, it will run, independent from the state of the file system. Some common make targets that are often phony are: all, install, clean, distclean, TAGS, info, check.
# sudo ssh-keygen -t rsa -f root_rsa
.PHONY: all
all:
	@echo use parameter
	@exit -1

.PHONY: proxmox-add-ssh-key
proxmox-add-ssh-key:
	ssh-copy-id -i ~/.ssh/root_rsa.pub -o "IdentityFile /root/root.pem" root@$(PVE1_IP)
	ssh-copy-id -i ~/.ssh/root_rsa.pub -o "IdentityFile /root/root.pem" root@$(PVE2_IP)
	ssh-copy-id -i ~/.ssh/root_rsa.pub -o "IdentityFile /root/root.pem" root@$(PVE3_IP)

.PHONY: proxmox-add-user
proxmox-add-user:
	ssh -v -i ~/.ssh/root_rsa -t root@$(PVE1_IP) bash -c '"adduser --quiet --disabled-password --shell /bin/bash --home /home/$(USER) --ingroup "sudo" --gecos "User" $(USER); echo "$(USER):$(PASSWD)" | chpasswd"'
	ssh -v -i ~/.ssh/root_rsa -t root@$(PVE2_IP) bash -c '"adduser --quiet --disabled-password --shell /bin/bash --home /home/$(USER) --ingroup "sudo" --gecos "User" $(USER); echo "$(USER):$(PASSWD)" | chpasswd"'
	ssh -v -i ~/.ssh/root_rsa -t root@$(PVE3_IP) bash -c '"adduser --quiet --disabled-password --shell /bin/bash --home /home/$(USER) --ingroup "sudo" --gecos "User" $(USER); echo "$(USER):$(PASSWD)" | chpasswd"'

.PHONY: proxmox-add-user-ssh-key
proxmox-add-user-ssh-key:
	ssh-copy-id -i ~/.ssh/id_rsa.pub -o "IdentityFile /home/$(USER)/$(USER).pem" $(USER)@$(PVE1_IP)
	ssh-copy-id -i ~/.ssh/id_rsa.pub -o "IdentityFile /home/$(USER)/$(USER).pem" $(USER)@$(PVE2_IP)
	ssh-copy-id -i ~/.ssh/id_rsa.pub -o "IdentityFile /home/$(USER)/$(USER).pem" $(USER)@$(PVE3_IP)

.PHONY: proxmox-copy-net-config
proxmox-copy-net-config:
	scp ./interfaces $(USER)@$(PVE1_IP):/home/$(USER)/
	scp ./firewall.sh $(USER)@$(PVE1_IP):/home/$(USER)/
	scp ./interfaces $(USER)@$(PVE2_IP):/home/$(USER)/
	scp ./firewall.sh $(USER)@$(PVE2_IP):/home/$(USER)/
	scp ./interfaces $(USER)@$(PVE3_IP):/home/$(USER)/
	scp ./firewall.sh $(USER)@$(PVE3_IP):/home/$(USER)/

.PHONY: proxmox-off-pve-apt
proxmox-off-pve-apt:
	ssh -v -i ~/.ssh/root_rsa -t root@$(PVE1_IP) bash -c '"true > /etc/apt/sources.list.d/pve-enterprise.list"'
	ssh -v -i ~/.ssh/root_rsa -t root@$(PVE2_IP) bash -c '"true > /etc/apt/sources.list.d/pve-enterprise.list"'
	ssh -v -i ~/.ssh/root_rsa -t root@$(PVE3_IP) bash -c '"true > /etc/apt/sources.list.d/pve-enterprise.list"'

.PHONY: proxmox-apt-upgrade
proxmox-apt-upgrade:
	ssh -v -i ~/.ssh/root_rsa -t root@$(PVE1_IP) bash -c '"apt-get update && apt-get upgrade -y"'
	ssh -v -i ~/.ssh/root_rsa -t root@$(PVE2_IP) bash -c '"apt-get update && apt-get upgrade -y"'
	ssh -v -i ~/.ssh/root_rsa -t root@$(PVE3_IP) bash -c '"apt-get update && apt-get upgrade -y"'

.PHONY: proxmox-init-ansible
proxmox-init-ansible:
# workaround for error - No module named 'distutils.cmd'
# proxmox's python3.9 has no distutils
# ansible needs python3 and pip3
	ssh -v -i ~/.ssh/root_rsa -t root@$(PVE1_IP) bash -c '"apt-get install -y python3.9-distutils && curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && python3 get-pip.py && pip3 install --ignore-installed ansible"'
	ssh -v -i ~/.ssh/root_rsa -t root@$(PVE2_IP) bash -c '"apt-get install -y python3.9-distutils && curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && python3 get-pip.py && pip3 install --ignore-installed ansible"'
	ssh -v -i ~/.ssh/root_rsa -t root@$(PVE3_IP) bash -c '"apt-get install -y python3.9-distutils && curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && python3 get-pip.py && pip3 install --ignore-installed ansible"'

.PHONY: proxmox-apt-install
proxmox-apt-install:
	ansible-playbook -i ../ansible-playbook/inventory-proxmox.yaml ../ansible-playbook/proxmox-apt-install.yaml -u root --private-key ~/.ssh/root_rsa

## fail
.PHONY: proxmox-install-docker
proxmox-install-docker:
	ansible-playbook -i ../ansible-playbook/inventory-proxmox.yaml ../ansible-playbook/proxmox-install-docker.yaml -u root  --private-key ~/.ssh/root_rsa

.PHONY: proxmox-add-admin-group
proxmox-add-admin-group:
	ansible-playbook -i ../ansible-playbook/inventory-proxmox.yaml ../ansible-playbook/proxmox-create-group.yaml -u root  --private-key ~/.ssh/root_rsa

.PHONY: proxmox-install-zerotier
proxmox-install-zerotier:
	ansible-playbook -i ../ansible-playbook/inventory-proxmox.yaml ../ansible-playbook/proxmox-install-zerotier.yaml -u root  --private-key ~/.ssh/root_rsa

.PHONY: reboot
reboot:
	ansible-playbook -i ../ansible-playbook/inventory-proxmox.yaml ../ansible-playbook/reboot.yaml -u root

.PHONY: restart-service
restart-service:
	ssh -v -i ~/.ssh/root_rsa -t root@$(PVE1_IP) \
	bash -c '"systemctl restart pvedaemon pveproxy"'
	ssh -v -i ~/.ssh/root_rsa -t root@$(PVE2_IP) \
	bash -c '"systemctl restart pvedaemon pveproxy"'
	ssh -v -i ~/.ssh/root_rsa -t root@$(PVE3_IP) \
	bash -c '"systemctl restart pvedaemon pveproxy"'

define ADD_TF_USER
pveum role add TerraformProv -privs \"VM.Allocate VM.Clone VM.Config.CDROM VM.Config.CPU VM.Config.Cloudinit VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Monitor VM.Audit VM.PowerMgmt Datastore.AllocateSpace Datastore.Audit\" \
&& pveum user add terraform-prov@pve \
&& pveum aclmod / -user terraform-prov@pve -role TerraformProv
endef

.PHONY: proxmox-terraform-add
proxmox-terraform-add:
	ssh -v -i ~/.ssh/root_rsa -t root@$(PVE2_IP) \
	bash -c '"$(ADD_TF_USER)"'

.PHONY: proxmox-terraform-copy-key
proxmox-terraform-copy-key:
	ssh -v -i terraform/id_rsa terraform-prov@$(PVE1_IP)

.PHONY: proxmox-terraform-del
proxmox-terraform-del:
	ssh -v -i ~/.ssh/root_rsa -t root@$(PVE1_IP) \
	bash -c '"pveum user del terraform-prov@pve && pveum role del TerraformProv"'


define CREATE_TEMPLATE
wget http://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img \
&& qm create 9000 --memory 2048 --net0 virtio,bridge=vmbr0 \
&& qm importdisk 9000 jammy-server-cloudimg-amd64.img local --format qcow2 \
&& qm set 9000 --scsihw virtio-scsi-pci --scsi0 local:9000/vm-9000-disk-0.qcow2 \
&& qm set 9000 --ide2 local:cloudinit \
&& qm set 9000 --boot c --bootdisk scsi0 \
&& qm set 9000 --serial0 socket --vga serial0 \
&& qm template 9000
endef

define DOWNLOAD_LXD_TEMPLATE
pveam update \
&& pveam download local ubuntu-22.04-standard_22.04-1_amd64.tar.zst
endef

.PHONY: proxmox-create-template
proxmox-create-template:
	ssh -v -i ~/.ssh/root_rsa -t root@$(PVE1_IP) \
	bash -c '"$(CREATE_TEMPLATE)"'

.PHONY: proxmox-destroy-template
proxmox-destroy-template:
	ssh -v -i ~/.ssh/root_rsa -t root@$(PVE1_IP) \
	bash -c '"qm destroy 9000"'

define DOWNLOAD_LXD_TEMPLATE
pveam update \
&& pveam download local ubuntu-22.04-standard_22.04-1_amd64.tar.zst
endef

.PHONY: proxmox-down-lxd-template
proxmox-down-lxd-template:
	ssh -v -i ~/.ssh/root_rsa -t root@$(PVE1_IP) \
	bash -c '"$(DOWNLOAD_LXD_TEMPLATE)"'


refresh:
	cd terraform && terraform refresh

upgrade:
	cd terraform && terraform init -upgrade

format:
	cd terraform && terraform fmt

plan:
	cd terraform && terraform plan

apply:
	cd terraform && terraform apply --auto-approve -lock=false

clean:
	cd terraform && rm -rf .terraform/ *.backup *.tfstate
