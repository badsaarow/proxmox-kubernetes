resource "proxmox_lxc" "gateway" {
  for_each = var.gateways

  features {
    nesting = true
  }
  ostemplate = var.common.os_template
  ostype     = var.common.os_type

  cores      = each.value.cores
  hostname   = each.key
  vmid       = each.value.id
  memory     = each.value.memory
  dynamic "network" {
    for_each = each.value.network

    content {
      name     = network.value.name
      bridge   = "vmbr0"
      firewall = false
      gw       = network.value.gw
      ip       = network.value.cidr
      rate     = 0
      tag      = 0
      type     = "veth"
    }
  }
  searchdomain = var.common.search_domain
  swap     = 2048
  onboot   = true
  pool = "admin-pool"
  password = yamldecode(data.local_file.secrets.content).root_password

// Terraform will crash without rootfs defined
  rootfs   {
      storage = "local"
      size = "${each.value.disk}G"
  }
  ssh_public_keys = join("", [
    data.tls_public_key.bastion.public_key_openssh,
    data.tls_public_key.vm.public_key_openssh
  ])
  start = true
  unprivileged = true
  target_node  = each.value.target_node
}
