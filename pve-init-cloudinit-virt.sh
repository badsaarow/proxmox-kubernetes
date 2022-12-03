#!/usr/bin/bash
# executed inside cloudinit template
# called by pve-init-cloudinit.sh
# run by root
. /root/.env

echo "root:$PASSWD" | chpasswd
adduser --quiet --disabled-password --shell /bin/bash --home /home/terraform-prov --ingroup sudo --gecos User terraform-prov
echo "terraform-prov:$PASSWD" | chpasswd
