## setup
https://cloud-images.ubuntu.com/jammy/current/

iso target: /var/lib/vz/template/iso/proxmox-ve_8.0-2.iso

```
qm create 9200 --name jammy-server-cloudimg-amd64 --memory 4096 --cpu cputype=host --cores 4 --serial0 socket --vga serial0 --net0 virtio,bridge=vmbr0,tag=20 --agent enabled=1,fstrim_cloned_disks=1
qm importdisk 9200 ./jammy-server-cloudimg-amd64.img local-lvm -format qcow2
qm set 9200 --scsihw virtio-scsi-pci --scsi0 local-lvm:9200/vm-9200-disk-0.qcow2,ssd=1,discard=on
qm template 9200

Successfully imported disk as 'unused0:local-lvm:vm-9200-disk-0'
lvm name '9200/vm-9200-disk-0.qcow2' contains illegal characters

```


```bash
apt install cloud-utils

root@pveNode03:~/homelab-infrastructure/k3s# ./create-k3s-seed-iso.sh k3s-c
node k3s-c found
./create-k3s-seed-iso.sh: line 39: /root/homelab-infrastructure/.env: No such file or directory

######################################################################
# creating k3s-seed ISO for k3s-c
######################################################################
touching meta-data file
populating variables to temporary user-data file
running 'cloud-localds k3s-seed-k3s-c.iso user-data meta-data'
copying seed ISO to proxmox
k3s-seed-k3s-c.iso                                                                                                                                          100%  366KB 119.0MB/s   00:00
root@pveNode03:~/homelab-infrastructure/k3s# ls
arm64  create-k3s-seed-iso.sh  k3s-seed-k3s-0.iso  k3s-seed-k3s-a.iso  k3s-seed-k3s-b.iso  k3s-seed-k3s-c.iso  nodes  README.md
```

root@pveNode03:~/homelab-infrastructure/k3s# pvesm status
Name             Type     Status           Total            Used       Available        %
local             dir     active        98497780         7862984        85585248    7.98%

```bash
new_vm_id=401
new_vm_prefix=0
qm clone 9200 $new_vm_id --name k3s-$new_vm_prefix --format raw --full --storage local-lvm
qm resize $new_vm_id scsi0 100G
qm status $new_vm_id
# wait
qm set $new_vm_id --boot c --bootdisk scsi0
qm set $new_vm_id -cdrom /var/lib/vz/template/iso/k3s-seed-k3s-$new_vm_prefix.iso
qm migrate $new_vm_id pveNode03  --with-local-disks --online
```
