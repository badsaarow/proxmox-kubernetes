all:
	@echo use parameter
	@exit -1

# proxmox-set-network:
# 	ssh -v -t root@192.168.123.4 echo 'nameserver 1.1.1.1' > /etc/resolv.conf
# 	ssh -v -t root@192.168.123.64 echo 'nameserver 1.1.1.1' > /etc/resolv.conf

proxmox-add-ssh-key:


add-ssh-key:



proxmox-off-pve-apt:
		ssh -v -i ~/.ssh/id_rsa.pub -t root@192.168.1.6 bash -c '"true > /etc/apt/sources.list.d/pve-enterprise.list"'
		ssh -v -i ~/.ssh/id_rsa.pub -t root@192.168.1.5 bash -c '"true > /etc/apt/sources.list.d/pve-enterprise.list"'

proxmox-add-user:


apt-upgrade:



proxmox-init-ansible:
# workaround for error - No module named 'distutils.cmd'
# proxmox's python3.9 has no distutils
# ansible needs python3 and pip3


proxmox-apt-install:
	ansible-playbook -i inventory-proxmox.yaml proxmox-apt-install.yaml -u root
	# ansible-playbook -i inventory-vm.yaml proxmox-apt-install.yaml

apt-install:

brew-install:

brew-upgrade:
## not for proxmox
	ansible-playbook  -i inventory-vm.yaml  upgrade_brew.yaml

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

proxmox-install-docker:
	ansible-playbook -i inventory-proxmox.yaml install_docker.yaml -u root

proxmox-add-admin-group:
	ansible-playbook -i inventory-proxmox.yaml proxmox-create-group.yaml -u root

reboot:
	ansible-playbook -i inventory-proxmox.yaml reboot.yaml -u root

change-hostname:
	ansible-playbook -i inventory-proxmox.yaml change-hostname.yaml

install-tailscale:
	ansible-playbook -i inventory-proxmox.yaml install-tailscale.yaml -u root

zerotier-join:
	ansible-playbook -i inventory-proxmox.yaml zerotier-join.yaml -u root

# ansible-playbook -i "localhost," -c local ansible_osx.yml --ask-become-pass
