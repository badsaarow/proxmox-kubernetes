data "local_file" "secrets" {
  filename = "./.terraform_secret.yaml"
}

data "tls_public_key" "bastion" {
  private_key_pem = yamldecode(data.local_file.secrets.content).bastion_private_key
}

data "tls_public_key" "vm" {
  private_key_pem = yamldecode(data.local_file.secrets.content).terraform_private_key
}
