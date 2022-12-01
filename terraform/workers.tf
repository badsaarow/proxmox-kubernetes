resource "proxmox_vm_qemu" "kube-worker" {
  for_each = var.workers

  name        = each.key
  target_node = each.value.target_node
  agent       = 1
  automatic_reboot = true
  balloon     = 0
  bios        = "seabios"
  clone       = var.common.clone
  full_clone  = false
  vmid        = each.value.id
  memory      = each.value.memory
  cores       = each.value.cores
  force_create              = false
  hotplug                   = "network,disk,usb"
  kvm                       = true
  numa                      = false
  onboot                    = false
  oncreate                  = true
  os_type                   = "cloud-init"
  qemu_os                   = "l26"
  scsihw                    = "virtio-scsi-pci"
  sockets                   = 1
  tablet                    = true
  vcpus                     = 0
  vga {
    type = "qxl"
  }
  network {
      model    = "virtio"
      bridge   = "vmbr0"
      firewall = false
      link_down = false
  }
  disk {
    type         = "scsi"
    cache        = "none"
    storage      = "local"
    size         = each.value.disk
    format       = "qcow2"
  }
  serial {
    id   = 0
    type = "socket"
  }
  bootdisk   = "scsi0"

  ipconfig0  = "ip=${each.value.cidr},gw=${each.value.gw}"
  ciuser     = "terraform-prov"
  cipassword = yamldecode(data.local_file.secrets.content).user_password
  # cipassword   = "**********" # un-comment after creation
  searchdomain = var.common.search_domain
  nameserver   = var.common.nameserver
  sshkeys = join("", [
    data.tls_public_key.bastion.public_key_openssh,
    data.tls_public_key.vm.public_key_openssh
  ])

  depends_on = [
    proxmox_vm_qemu.kube-master
  ]
}
