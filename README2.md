## setup
```
qm create 9200 --name jammy-server-cloudimg-amd64 --memory 4096 --cpu cputype=host --cores 4 --serial0 socket --vga serial0 --net0 virtio,bridge=vmbr0,tag=20 --agent enabled=1,fstrim_cloned_disks=1
qm importdisk 9200 ./jammy-server-cloudimg-amd64.img local-lvm -format qcow2
qm set 9200 --scsihw virtio-scsi-pci --scsi0 local-lvm:9200/vm-9200-disk-0.qcow2,ssd=1,discard=on
qm template 9200

Successfully imported disk as 'unused0:local-lvm:vm-9200-disk-0'
lvm name '9200/vm-9200-disk-0.qcow2' contains illegal characters

```

```bash
qm clone 9200 402 --name k3s-c --format raw --full --storage zfs-prox
qm resize 402 scsi0 200G
qm set 402 --boot c --bootdisk scsi0
qm set 402 -cdrom /mnt/pve/proxmox/template/iso/k3s-seed-k3s-c.iso
qm migrate 402 proxmox-c --with-local-disks --online
```
