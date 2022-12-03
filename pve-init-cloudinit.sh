#!/usr/bin/bash
. /root/.env

virt-customize  -a $CI_IMG \
  --upload .env:/root/ \
  --upload pve-init-cloudinit-virt.sh:/root/ \
  --upload id_rsa:/root/ \
  --upload id_rsa.pub:/root/ \
  --upload root_rsa:/root/ \
  --upload root_rsa.pub:/root/

virt-customize  -a $CI_IMG \
  --run /root/pve-init-cloudinit-virt.sh

virt-customize  -a $CI_IMG \
  --update \
  --timezone Asia/Seoul \
  --install qemu-guest-agent,net-tools,vim,bash-completion,wget,curl,telnet,unzip

# docker-ce,docker-ce-cli,containerd.io,docker-compose-plugin

virt-customize  -a $CI_IMG --update

