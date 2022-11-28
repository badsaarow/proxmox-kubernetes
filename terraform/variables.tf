variable "common" {
  type = map(string)
  default = {
    clone         = "VM 9001"
    target_node   = "node-02"
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
          cidr   = "10.10.10.101/24"
          name   = "eth0"
          gw     = "10.10.10.1"
          hwaddr = "06:08:72:DD:89:B4"
          ip     = "10.10.10.101"
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
          cidr   = "10.10.10.102/24"
          name   = "eth0"
          gw     = "10.10.10.1"
          hwaddr = "E6:48:8F:0C:D0:57"
          ip     = "10.10.10.102"
        }
    ] }
  }
}

variable "masters" {
  type = map(map(string))
  default = {
    kube-master1 = {
      id      = 2001
      cidr    = "10.10.10.111/24"
      cores   = 2
      gw      = "10.10.10.1"
      macaddr = "6E:DE:EE:62:37:1D"
      ip      = "10.10.10.111"
      memory  = 2048
      disk    = "40G"
    },
    kube-master2 = {
      id      = 2002
      cidr    = "10.10.10.112/24"
      cores   = 2
      gw      = "10.10.10.1"
      macaddr = "2E:6E:FC:F0:A1:CB"
      ip      = "10.10.10.112"
      memory  = 2048
      disk    = "40G"
    },
    kube-master3 = {
      id      = 2003
      cidr    = "10.10.10.113/24"
      cores   = 2
      gw      = "10.10.10.1"
      macaddr = "6A:83:72:97:97:81"
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
      id      = 3001
      cidr    = "10.10.10.121/24"
      cores   = 2
      gw      = "10.10.10.1"
      macaddr = "62:0E:E4:E4:7B:46"
      ip      = "10.10.10.121"
      memory  = 5120
      disk    = "80G"
    },
    kube-worker2 = {
      id      = 3002
      cidr    = "10.10.10.122/24"
      cores   = 2
      gw      = "10.10.10.1"
      macaddr = "5A:B1:D9:D1:E6:35"
      ip      = "10.10.10.122"
      memory  = 5120
      disk    = "80G"
    },
    kube-worker3 = {
      id      = 3003
      cidr    = "10.10.10.123/24"
      cores   = 2
      gw      = "10.10.10.1"
      macaddr = "22:92:5D:6B:7F:A1"
      ip      = "10.10.10.123"
      memory  = 5120
      disk    = "80G"
    },
  }
}
