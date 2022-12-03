#!/usr/bin/bash
. /root/.env
qm destroy 9001 --destroy-unreferenced-disks --purge true
qm create 9001 --memory 2048 --net0 virtio,bridge=vmbr0
qm importdisk 9001  jammy-server-cloudimg-amd64.img local --format qcow
qm set 9001 \
  --scsihw virtio-scsi-pci --scsi0 local:9001/vm-9001-disk-0.qcow2 \
  --agent enabled=1,fstrim_cloned_disks=1 \
  --name 9001 \
  --ide2 9001:cloudinit \
  --boot c --bootdisk scsi0 \
  --serial0 socket --vga serial0
qm template 9001
