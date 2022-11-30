terraform {
  required_version = ">= 1.1.0"
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = ">= 2.9.5"
    }
  }
}

provider "proxmox" {
  pm_tls_insecure = true
  pm_api_url      = yamldecode(data.local_file.secrets.content).pm_api_url
  pm_api_token_id = yamldecode(data.local_file.secrets.content).pm_api_token_id
  pm_api_token_secret = yamldecode(data.local_file.secrets.content).pm_api_token_secret
  # pm_user         = yamldecode(data.local_file.secrets.content).pm_user
  # pm_password     = yamldecode(data.local_file.secrets.content).pm_password

  pm_otp = ""
  pm_debug      = true
  pm_log_enable = true
  pm_log_file   = "terraform-plugin-proxmox.log"
  pm_log_levels = {
    _default    = "debug"
    _capturelog = ""
  }
}

provider "tls" {
}

provider "random" {
}

provider "local" {
}
