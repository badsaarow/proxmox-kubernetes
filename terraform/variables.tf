variable "common" {
  type = map(string)
  default = {
    clone         = "qemu-guest"
    target_node   = "hci-external-1"
    os_template   = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
    os_type       = "ubuntu"
  }
}

variable "gateways" {
  type = map(any)
  default = {
    gateway1 = {
      id     = 101
      cores  = 2
      memory = 2048
      disk   = 16
      network = [
        {
          cidr   = "10.10.10.101/24"
          name   = "eth0"
          gw     = "10.10.10.1"
          ip     = "10.10.10.101"
        }
      ]
    }
    gateway2 = {
      id     = 102
      cores  = 2
      memory = 2048
      disk   = 16
      network = [
        {
          cidr   = "10.10.10.102/24"
          name   = "eth0"
          gw     = "10.10.10.1"
          ip     = "10.10.10.102"
        }
    ] }
  }
}

variable "masters" {
  type = map(map(string))
  default = {
    kube-master1 = {
      id      = 201
      cidr    = "10.10.10.111/24"
      cores   = 2
      gw      = "10.10.10.1"
      ip      = "10.10.10.111"
      memory  = 2048
      disk    = "40G"
    },
    kube-master2 = {
      id      = 202
      cidr    = "10.10.10.112/24"
      cores   = 2
      gw      = "10.10.10.1"
      ip      = "10.10.10.112"
      memory  = 2048
      disk    = "40G"
    },
    kube-master3 = {
      id      = 203
      cidr    = "10.10.10.113/24"
      cores   = 2
      gw      = "10.10.10.1"
      ip      = "10.10.10.113"
      memory  = 2048
      disk    = "40G"
    }
  }
}

variable "workers" {
  type = map(map(string))
  default = {
    kube-worker1 = {
      id      = 301
      cidr    = "10.10.10.121/24"
      cores   = 2
      gw      = "10.10.10.1"
      ip      = "10.10.10.121"
      memory  = 5120
      disk    = "80G"
    },
    kube-worker2 = {
      id      = 302
      cidr    = "10.10.10.122/24"
      cores   = 2
      gw      = "10.10.10.1"
      ip      = "10.10.10.122"
      memory  = 5120
      disk    = "80G"
    },
    kube-worker3 = {
      id      = 303
      cidr    = "10.10.10.123/24"
      cores   = 2
      gw      = "10.10.10.1"
      ip      = "10.10.10.123"
      memory  = 5120
      disk    = "80G"
    },
  }
}
