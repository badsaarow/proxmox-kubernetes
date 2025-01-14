#!/usr/bin/bash
. /root/.env
cat /root/.env

qm destroy $VM_TEMPLATE_ID --destroy-unreferenced-disks --purge true
qm create $VM_TEMPLATE_ID --memory 2048 --net0 virtio,bridge=vmbr0
qm importdisk $VM_TEMPLATE_ID  jammy-server-cloudimg-amd64.img local --format qcow2
qm set $VM_TEMPLATE_ID \
  --scsihw virtio-scsi-pci --scsi0 local:$VM_TEMPLATE_ID/vm-$VM_TEMPLATE_ID-disk-0.qcow2 \
  --agent enabled=1,fstrim_cloned_disks=1 \
  --name $VM_NAME \
  --ide2 local:cloudinit \
  --boot c --bootdisk scsi0 \
  --serial0 socket --vga serial0
qm template $VM_TEMPLATE_ID
