resource "proxmox_vm_qemu" "kube-master" {
  for_each = var.masters

  name        = each.key
  target_node = var.common.target_node
  # The destination resource pool for the new VM
  pool = "k8s-pool"
  # Activate QEMU agent for this VM
  agent       = 1
  # The template name to clone this vm from
  clone       = var.common.clone
  define_connection_info = true
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

  sshkeys = join("", [
    data.tls_public_key.bastion.public_key_openssh,
    data.tls_public_key.vm.public_key_openssh
  ])

  depends_on = [
    proxmox_lxc.gateway
  ]

  connection {
    type     = "ssh"
    host                = each.value.ip
    user                = "terraform-prov"
    password            = yamldecode(data.local_file.secrets.content).root_password
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
