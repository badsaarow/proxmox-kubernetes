#!/usr/bin/bash
. .env

virt-customize -v -a $CI_IMG \
  --upload .env:/root/ \
  --upload pve-init-cloudinit-virt.sh:/root/ \
  --upload terraform/id_rsa:/root/ \
  --upload terraform/id_rsa.pub:/root/ \
  --upload terraform/root_rsa:/root/ \
  --upload terraform/root_rsa.pub:/root/

virt-customize -v -a $CI_IMG \
	--run /root/pve-init-cloudinit-virt.sh

virt-customize -v -a $CI_IMG \
  --update \
 	--timezone Asia/Seoul \
  --ssh-inject $USER:file:/home/$USER/id_rsa.pub \
 	--install qemu-guest-agent,net-tools,vim,bash-completion,wget,curl,telnet,unzip,docker-ce,docker-ce-cli,containerd.io,docker-compose-plugin

virt-customize -v -a $CI_IMG \
  --update
qm destroy $VM_ID --destroy-unreferenced-disks --purge true
qm create $VM_ID --memory 2048 --net0 virtio,bridge=vmbr0
qm importdisk $VM_ID $CI_IMG $STORAGE_POOL --format qcow
qm set $VM_ID --scsihw virtio-scsi-pci --scsi0 $STORAGE_POOL:$VM_ID/vm-$VM_ID-disk-0.qcow2
qm set $VM_ID --agent enabled=1,fstrim_cloned_disks=1
qm set $VM_ID --name $VM_NAME
qm set $VM_ID --ide2 $STORAGE_POOL:cloudinit
qm set $VM_ID --boot c --bootdisk scsi0
qm set $VM_ID --serial0 socket --vga serial0
qm template $VM_ID
