resource "proxmox_vm_qemu" "kube-worker" {
  for_each = var.workers

  name        = each.key
  target_node = var.common.target_node
  agent       = 1
  automatic_reboot = true
  balloon     = 0
  bios        = "seabios"
  clone       = var.common.clone
  vmid        = each.value.id
  memory      = each.value.memory
  cores       = each.value.cores
  define_connection_info    = true
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
    macaddr  = each.value.macaddr
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
  cipassword = yamldecode(data.local_file.secrets.content).user_password # comment after creation
  # cipassword   = "**********" # un-comment after creation

  sshkeys = join("", [
    data.tls_public_key.bastion.public_key_openssh,
    data.tls_public_key.vm.public_key_openssh
  ])

  depends_on = [
    proxmox_vm_qemu.kube-master
  ]

  connection {
    type     = "ssh"
    host                = each.value.ip
    user                = "terraform-prov"
    private_key         = data.tls_public_key.vm.private_key_pem
    bastion_host        = yamldecode(data.local_file.secrets.content).bastion_host
    bastion_private_key = data.tls_public_key.bastion.private_key_pem
  }

  provisioner "remote-exec" {
    inline = [
      "sudo usermod --password $(openssl passwd -1 ${yamldecode(data.local_file.secrets.content).root_password}}) root",
      "ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N \"\"",
      "echo \"${data.tls_public_key.vm.private_key_pem}\" > ~/.ssh/id_rsa",
      "echo \"${data.tls_public_key.vm.public_key_openssh}\" > ~/.ssh/id_rsa.pub",
    ]
  }
}
