## setup

### pveNode2
```bash
root@pveNode02:~# qm create 9300 --name jammy-server-cloudimg-amd64 --memory 4096 --cpu cputype=host --cores 4 --serial0 socket --vga serial0 --net0 virtio,bridge=vmbr0,tag=20 --agent enabled=1,fstrim_cloned_disks=1
root@pveNode02:~# qm importdisk 9300 ./jammy-server-cloudimg-amd64.img local-lvm -format qcow2
./jammy-server-cloudimg-amd64.img: non-existent or non-regular file

root@pveNode02:~# scp pveNode03:jammy-server-cloudimg-amd64.img .
jammy-server-cloudimg-amd64.img                                                                                                                                                                                              100%  655MB 112.0MB/s   00:05

root@pveNode02:~# qm importdisk 9300 ./jammy-server-cloudimg-amd64.img local-lvm -format qcow2
importing disk './jammy-server-cloudimg-amd64.img' to VM 9300 ...
  Logical volume "vm-9300-disk-0" created.

root@pveNode02:~# qm set 9300 --scsihw virtio-scsi-pci --scsi0 local-lvm:9300/vm-9300-disk-0.qcow2,ssd=1,discard=on
lvm name '9300/vm-9300-disk-0.qcow2' contains illegal characters

root@pveNode02:~# qm set 9300 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9300-disk-0,ssd=1,discard=on

root@pveNode02:~# qm set 9300 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9300-disk-0,ssd=1,discard=on
update VM 9300: -scsi0 local-lvm:vm-9300-disk-0,ssd=1,discard=on -scsihw virtio-scsi-pci

root@pveNode02:~# qm template 9300


apt install cloud-utils


root@pveNode02:~/homelab-infrastructure/k3s# ./create-k3s-seed-iso.sh k3s-0
root@pveNode02:~/homelab-infrastructure/k3s# ./create-k3s-seed-iso.sh k3s-a
root@pveNode02:~/homelab-infrastructure/k3s# ./create-k3s-seed-iso.sh k3s-b
root@pveNode02:~/homelab-infrastructure/k3s# ./create-k3s-seed-iso.sh k3s-c
root@pveNode02:~/homelab-infrastructure/k3s# mv *.iso ~/



new_vm_id=302
new_vm_prefix=0
qm clone 9300 $new_vm_id --name k3s-$new_vm_prefix --format raw --full --storage local-lvm
qm resize $new_vm_id scsi0 100G
qm status $new_vm_id
# wait
qm set $new_vm_id --boot c --bootdisk scsi0
qm set $new_vm_id -cdrom /var/lib/vz/template/iso/k3s-seed-k3s-$new_vm_prefix.iso
qm migrate $new_vm_id pveNode02  --with-local-disks --online


root@pveNode02:~# pvecm nodes

Membership information
----------------------
    Nodeid      Votes Name
         1          1 pveNode03
         2          1 pveNode02 (local)
root@pveNode02:~# qm migrate $new_vm_id pveNode03  --with-local-disks --online
VM isn't running. Doing offline migration instead.
2023-08-09 17:31:27 starting migration of VM 301 to node 'pveNode03' (192.168.0.78)
2023-08-09 17:31:28 migration finished successfully (duration 00:00:02)
root@pveNode02:~# qm list
      VMID NAME                 STATUS     MEM(MB)    BOOTDISK(GB) PID
      9300 jammy-server-cloudimg-amd64 stopped    4096               0.00 0



new_vm_id=302
new_vm_prefix=0
qm clone 9300 $new_vm_id --name k3s-$new_vm_prefix --format raw --full --storage local-lvm
qm resize $new_vm_id scsi0 100G
qm status $new_vm_id
# wait
qm set $new_vm_id --boot c --bootdisk scsi0
qm set $new_vm_id -cdrom /var/lib/vz/template/iso/k3s-seed-k3s-$new_vm_prefix.iso

```

```bash
root@pveNode02:~# new_vm_id=305
new_vm_prefix=c
qm clone 9300 $new_vm_id --name k3s-$new_vm_prefix --format raw --full --storage local-lvm
qm resize $new_vm_id scsi0 100G
qm status $new_vm_id
# wait
qm set $new_vm_id --boot c --bootdisk scsi0
qm set $new_vm_id -cdrom /var/lib/vz/template/iso/k3s-seed-k3s-$new_vm_prefix.iso
disk 'scsi0' does not exist
status: stopped
update VM 305: -boot c -bootdisk scsi0
update VM 305: -cdrom /var/lib/vz/template/iso/k3s-seed-k3s-c.iso
root@pveNode02:~# qm list
      VMID NAME                 STATUS     MEM(MB)    BOOTDISK(GB) PID
       302 k3s-0                stopped    4096               0.00 0
       303 k3s-a                stopped    4096               0.00 0
       304 k3s-b                stopped    4096               0.00 0
       305 k3s-c                stopped    4096               0.00 0
      9300 jammy-server-cloudimg-amd64 stopped    4096               0.00 0
root@pveNode02:~# qm start 302 303 304 305
400 too many arguments
qm start <vmid> [OPTIONS]
root@pveNode02:~# qm start 302
root@pveNode02:~# qm start 303
root@pveNode02:~# qm start 304
root@pveNode02:~# qm start 305
```



### pveNode3

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
