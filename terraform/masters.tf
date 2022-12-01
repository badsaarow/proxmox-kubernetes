resource "proxmox_vm_qemu" "kube-master" {
  for_each = var.masters

  name        = each.key
  target_node = each.value.target_node
  # The destination resource pool for the new VM
  pool        = "k8s-pool"
  # Activate QEMU agent for this VM
  agent       = 1
  # The template name to clone this vm from
  clone       = var.common.clone
  full_clone = false
  vmid        = each.value.id
  memory      = each.value.memory
  cores       = each.value.cores
  vga {
    type = "qxl"
  }
  network {
      model    = "virtio"
      bridge   = "vmbr0"
      firewall = false
  }
  disk {
    type         = "scsi"
    storage      = "local"
    size         = each.value.disk
    format       = "qcow2"
  }
  serial {
    id   = 0
    type = "socket"
  }

  sockets = 1
  vcpus = 0
  cpu = "host"
  bootdisk   = "scsi0"
  scsihw     = "virtio-scsi-pci"
  os_type    = "cloud-init"
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
    proxmox_lxc.gateway
  ]
}
