#!/usr/bin/bash
# executed inside cloudinit template
# called by pve-init-cloudinit.sh
# run by root
. /root/.env

cat /root/.env
echo $PASSWD
echo "root:$PASSWD" | chpasswd
adduser --quiet --disabled-password --shell /bin/bash --home /home/terraform --ingroup sudo --gecos User terraform
echo "terraform:$PASSWD" | chpasswd
