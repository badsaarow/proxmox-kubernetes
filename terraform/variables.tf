variable "common" {
  type = map(string)
  default = {
    clone         = "VM 9002"
    target_node   = "hci-internal-2"
    os_template   = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
    os_type       = "ubuntu"
  }
}

variable "gateways" {
  type = map(any)
  default = {
    gateway1 = {
      id     = 1001
      cores  = 2
      memory = 2048
      disk   = 16
      network = [
        {
          cidr   = "10.10.20.101/24"
          name   = "eth0"
          gw     = "10.10.20.1"
          ip     = "10.10.20.101"
        }
      ]
    }
    gateway2 = {
      id     = 1002
      cores  = 2
      memory = 2048
      disk   = 16
      network = [
        {
          cidr   = "10.10.20.102/24"
          name   = "eth0"
          gw     = "10.10.20.1"
          ip     = "10.10.20.102"
        }
    ] }
  }
}

variable "masters" {
  type = map(map(string))
  default = {
    kube-master1 = {
      id      = 2001
      cidr    = "10.10.20.111/24"
      cores   = 2
      gw      = "10.10.20.1"
      ip      = "10.10.20.111"
      memory  = 2048
      disk    = "40G"
    },
    kube-master2 = {
      id      = 2002
      cidr    = "10.10.20.112/24"
      cores   = 2
      gw      = "10.10.20.1"
      ip      = "10.10.20.112"
      memory  = 2048
      disk    = "40G"
    },
    kube-master3 = {
      id      = 2003
      cidr    = "10.10.20.113/24"
      cores   = 2
      gw      = "10.10.20.1"
      ip      = "10.10.20.113"
      memory  = 2048
      disk    = "40G"
    }
  }
}

variable "workers" {
  type = map(map(string))
  default = {
    kube-worker1 = {
      id      = 3001
      cidr    = "10.10.20.121/24"
      cores   = 2
      gw      = "10.10.20.1"
      macaddr = "62:0E:E4:E4:7B:46"
      ip      = "10.10.20.121"
      memory  = 5120
      disk    = "80G"
    },
    kube-worker2 = {
      id      = 3002
      cidr    = "10.10.20.122/24"
      cores   = 2
      gw      = "10.10.20.1"
      ip      = "10.10.20.122"
      memory  = 5120
      disk    = "80G"
    },
    kube-worker3 = {
      id      = 3003
      cidr    = "10.10.20.123/24"
      cores   = 2
      gw      = "10.10.20.1"
      ip      = "10.10.20.123"
      memory  = 5120
      disk    = "80G"
    },
  }
}
