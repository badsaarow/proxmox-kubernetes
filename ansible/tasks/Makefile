all:
	@echo use parameter
	@exit -1


proxmox-off-pve-apt:
		ssh -v -i ~/.ssh/id_rsa.pub -t root@192.168.1.6 bash -c '"true > /etc/apt/sources.list.d/pve-enterprise.list"'
		ssh -v -i ~/.ssh/id_rsa.pub -t root@192.168.1.5 bash -c '"true > /etc/apt/sources.list.d/pve-enterprise.list"'

proxmox-apt-install:
	ansible-playbook -i ../inventories/inventory-proxmox.yaml proxmox-apt-install.yaml -u root
	# ansible-playbook -i ../inventories/inventory-vm.yaml proxmox-apt-install.yaml

install-docker:
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo usermod -aG docker terraform
sudo passwd root

proxmox-add-admin-group:
	ansible-playbook -i ../inventories/inventory-proxmox.yaml proxmox-create-group.yaml -u root

reboot:
	ansible-playbook -i ../inventories/inventory-proxmox.yaml reboot.yaml -u root

change-hostname:
	ansible-playbook -i ../inventories/inventory-proxmox.yaml change-hostname.yaml

install-tailscale:
	ansible-playbook -i ../inventories/inventory-proxmox.yaml install-tailscale.yaml -u root
