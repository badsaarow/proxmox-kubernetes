
# Kubernetes on Proxmox

Using Terraform and Ansible to provision Proxmox VMs and configure a highly available Kubernetes cluster with co-located control plane nodes and etcd members.

## Features

- Two `gateways` LXC machines for the DNS servers and the load balancers of kube-apiserver
- Three `masters` QEMU VM machines for the Kubernetes control-plane nodes
- Three `workers` QEMU VM machines for the Kubernetes worker nodes
- Setup NAT gateway with the assigned public IP on the first `gateways` machine
- Disable swap and ensure iptables see bridged traffic for `masters` and `workers`
- Install QEMU guest agent, setup timezone, disable SSH password and IPv6
- Setup SSH key, configure root password and use `terraform` as default sudo user

## Prerequisite

Terraform and Ansible is required to run the provisioning and configuration tasks. You may install them on macOS using Homebrew.

```bash
brew install terraform ansible
```

Alternatively you may prepare your Ansible environment using `virtualenv`.

```bash
# Use python3 instead of the default python come with macOS
brew install python3

# Install virtualenv with pip3
pip3 install virtualenv

# Create new python virtual environment in .ansible directory
virtualenv .ansible

# Activate the virtual environment according to your shell (e.g. fish)
. .ansible/bin/activate.fish
```

## Terraform Secrets

The passwords and SSH keys used by Terraform are retrieved from the `terraform/.terraform_secret.yaml` file. You may generate new passwords and SSH keys with the following commands.

```bash
# Create a random password with length 24
openssl rand -base64 24

# Create a RSA ssh key in PEM format with comment and file path
ssh-keygen -t rsa -b 4096 -N "" -C "$USERNAME@$DOMAIN" -m pem -f "$PRIVATE_KEY"
ssh-keygen -t rsa -b 4096 -N "" -C "terraform-prov@pve" -m pem -f terraform-prov-rsa
```

For the full list of required passwords and SSH keys, you may refer to the below sample configuration.

```yaml
# Proxmox API host URL
pm_api_url: https://<api_host>:8006/api2/json
pm_api_token_id: <token>
pm_api_token_secret: <secret>
# Proxmox user (e.g. root@pam)
pm_user: <api_user>
# Proxmox password
pm_password: <api_password>
# Root password
root_password: <root_password>
# Cloud-init user (i.e. terraform) password
user_password: <user_password>
# Bastion host (i.e. proxy.hci.pve.cloud) name
bastion_host: <bastion_host>
# Key used by Terraform and Ansible to login to bastion host to execute tasks
bastion_private_key: |
-----BEGIN RSA PRIVATE KEY-----
-----END RSA PRIVATE KEY-----
# Key used by the default Terraform sudo user among all provisioned hosts
terraform_private_key: |
-----BEGIN RSA PRIVATE KEY-----
-----END RSA PRIVATE KEY-----
```

Make sure the bastion host has the terraform user and `terraform_private_key` authorized with `bastion_private_key`. Otherwise, use the first gateway host as the bastion host and configure the public IP in your DNS service provider. You also need to ensure the `bastion_private_key` is your default key in `~/.ssh/id_rsa` or specify the location in the SSH command of `ansible/group_vars/*.yml`.

## Container Template

LXC [containers](https://pve.proxmox.com/wiki/Linux_Container) are used to create the DNS and load balancers. You may update available containers and download the required template with the cluster shell in the console as follows.

```bash
# Update the container template database
pveam update

# Download the ubuntu container template
pveam download local ubuntu-22.04-standard_22.04-1_amd64.tar.zst
```

## Cloud-init Template

Virtual machines provisioned are initialized using [Cloud-init](https://pve.proxmox.com/wiki/Cloud-Init_Support). You need to create a cloud-init image and convert it to a VM template in order to further clone in the Terraform Proxmox [provider](https://github.com/Telmate/terraform-provider-proxmox) into VMs, resizing the disk, and configuring the default user, passwords, SSH keys and network. To prepare the template, you may use the following commands.

https://registry.terraform.io/modules/sdhibit/cloud-init-vm/proxmox/latest/examples/ubuntu_single_vm

```bash
# Download the ubuntu cloud image
wget http://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img

# Create a new VM with ID 9000
qm create 9000 --memory 2048 --net0 virtio,bridge=vmbr0

# Import the downloaded disk to local storage with qcow2 format
qm importdisk 9000 jammy-server-cloudimg-amd64.img local --format qcow2

# Attach the new disk to the VM as scsi drive
qm set 9000 --scsihw virtio-scsi-pci --scsi0 local:9000/vm-9000-disk-0.qcow2

# Add Cloud-Init CDROM drive
qm set 9000 --ide2 local:cloudinit

# Speed up booting by setting the bootdisk parameter
qm set 9000 --boot c --bootdisk scsi0

# Configure a serial console for display
qm set 9000 --serial0 socket --vga serial0

# Convert the VM into a template
qm template 9000
```

## Get Started

Provision all the machines using Terraform.
- https://github.com/Telmate/terraform-provider-proxmox/blob/master/docs/index.md

Create a new role for the future terraform user.
Create the user "terraform-prov@pve"
Add the TERRAFORM-PROV role to the terraform-prov user
Create admin-pool and k8s-pool

When make API Token, should uncheck **Privilege Segregation**
```
export PM_USER="terraform-prov@pve"
export PM_PASS="password"
```

```bash
# Navigate to the Terraform directory
cd terraform

# Initialize the Terraform state (on S3) and plugin
terraform init

# Set the one-time password for Proxmox API authentication
export PM_OTP=""
export PM_API_TOKEN_ID="terraform-prov@pve!terraform"
export PM_API_TOKEN_SECRET="3da67423-d40a-4265-85d4-432ee4248839"

# Check the resources to be created (optional)
terraform plan

# Apply the provisioning
terraform apply
```

Configure the Kubernetes cluster using Ansible with or without tags.

```bash
# Navigate to the Ansible directory
cd ansible

# Run the Ansible kubernetes playbook on inventory file
ansible-playbook -i inventories/hci kubernetes.yml

# Re-run playbook with tags if necessary (gateway/named/loadbalancer/common/runtime/kubeadm)
ansible-playbook -i inventories/hci kubernetes.yml -t <tags>
```
