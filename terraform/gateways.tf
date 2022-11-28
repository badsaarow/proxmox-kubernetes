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
  target_node  = var.common.target_node

  connection {
    type = "ssh"
    host                = each.value.network[0].ip
    user                = "root"
    password            = yamldecode(data.local_file.secrets.content).root_password
    private_key         = data.tls_public_key.vm.private_key_pem
    bastion_host        = yamldecode(data.local_file.secrets.content).bastion_host
    bastion_private_key = data.tls_public_key.bastion.private_key_pem
  }

  provisioner "remote-exec" {
    inline = [
      "adduser --disabled-password --gecos \"\" terraform-prov && usermod -aG sudo terraform-prov",
      "usermod --password $(openssl passwd -1 ${yamldecode(data.local_file.secrets.content).user_password}}) terraform-prov",
      "echo 'terraform-prov ALL=(ALL:ALL) NOPASSWD:ALL' >> /etc/sudoers.d/terraform-prov && chmod 440 /etc/sudoers.d/terraform-prov",
      "su - terraform-prov -c 'ssh-keygen -b 2048 -t rsa -f /home/terraform-prov/.ssh/id_rsa -q -N \"\"'",
      "echo \"${data.tls_public_key.vm.private_key_pem}\" > /home/terraform-prov/.ssh/id_rsa",
      "echo \"${data.tls_public_key.vm.public_key_openssh}\" > /home/terraform-prov/.ssh/id_rsa.pub",
      "echo \"${data.tls_public_key.vm.public_key_openssh}\" >> /home/terraform-prov/.ssh/authorized_keys",
      "echo \"${data.tls_public_key.bastion.public_key_openssh}\" >> /home/terraform-prov/.ssh/authorized_keys",
      "chown terraform-prov:terraform-prov /home/terraform-prov/.ssh/authorized_keys && chmod 700 /home/terraform-prov/.ssh/authorized_keys"
    ]
  }
}
