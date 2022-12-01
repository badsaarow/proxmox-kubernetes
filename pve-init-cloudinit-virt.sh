#!/usr/bin/bash
# executed inside cloudinit template
# called by pve-init-cloudinit.sh
# run by root
. .env

echo "root:$PASSWD" | chpasswd
deluser $USER
adduser --quiet --disabled-password --shell /bin/bash --home /home/$USER --ingroup sudo --gecos User $USER
echo "$USER:$PASSWD" | chpasswd

usermod --password $(openssl passwd -1 $PASSWD}) $USER
echo '$USER ALL=(ALL:ALL) NOPASSWD:ALL' >> /etc/sudoers.d/$USER && chmod 440 /etc/sudoers.d/$USER
su - $USER -c 'ssh-keygen -b 2048 -t rsa -f /home/$USER/.ssh/id_rsa -q -N \"\"'"'
echo /root/id_rsa > /home/$USER/.ssh/id_rsa
echo /root/id_rsa.pub > /home/$USER/.ssh/id_rsa.pub",
chown -r $USER:$USER /home/$USER/.ssh && chmod 700 /home/$USER/.ssh/authorized_keys"


# docker
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# k8s
apt-get install -y apt-transport-https ca-certificates curl
curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubs-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
apt-get update;apt-get upgrade -y
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

snap install -y k9s
