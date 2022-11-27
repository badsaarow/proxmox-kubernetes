data "local_file" "secrets" {
  filename = "./.terraform_secret.yaml"
}

data "tls_public_key" "ssh" {
  private_key_pem = yamldecode(data.local_file.secrets.content).ssh_key
}

data "tls_public_key" "vm_terraform" {
  private_key_pem = yamldecode(data.local_file.secrets.content).terraform_key
}
