variable "common" {
  type = map(string)
  default = {
    os_template   = "local:vztmpl/ubutu-lxc-22.04-2.tar.gz"
    os_type       = "ubuntu"
    nameserver    = "8.8.8.8"
  }
}

variable "masters" {
  type = map(map(string))
  default = {
    kube-master1 = {
      clone         = "9001"
      target_node   = "hci-external-1"
      id      = 2001
      cidr    = "10.10.10.111/24"
      cores   = 2
      gw      = "10.10.10.1"
      ip      = "10.10.10.111"
      memory  = 2048
      disk    = "40G"
    },
    kube-master2 = {
      clone         = "9002"
      target_node   = "hci-external-2"
      id      = 2002
      cidr    = "10.10.10.112/24"
      cores   = 2
      gw      = "10.10.10.1"
      ip      = "10.10.10.112"
      memory  = 2048
      disk    = "40G"
    },
    kube-master3 = {
      clone         = "9003"
      target_node   = "hci-external-3"
      id      = 2003
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
    clone         = "9001"
      target_node   = "hci-external-1"
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
      clone         = "9002"
      target_node   = "hci-external-2"
      id      = 3002
      cidr    = "10.10.10.122/24"
      cores   = 2
      gw      = "10.10.10.1"
      ip      = "10.10.10.122"
      memory  = 5120
      disk    = "80G"
    },
    kube-worker3 = {
      clone         = "9003"
      target_node   = "hci-external-3"
      id      = 3003
      cidr    = "10.10.10.123/24"
      cores   = 2
      gw      = "10.10.10.1"
      ip      = "10.10.10.123"
      memory  = 5120
      disk    = "80G"
    },
  }
}
