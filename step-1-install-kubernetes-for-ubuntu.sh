#su root
sudo apt-get install openssh-server
sudo apt-get install curl
apt install sshpass
sudo service ssh restart

#Note: All the commands in this tutorial should be run as a non-root user. If root access is required for the command, it will be preceded by sudo.
#First, add the GPG key for the official Docker repository to the system:
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Use the following command to set up the stable repository. You always need the stable repository, even if you want to install builds from the edge or test repositories as well. 
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

sudo apt-get update
apt-cache policy docker-ce
sudo apt-get install -y docker-ce
sudo systemctl status docker
sudo usermod -aG docker ${USER}
su - ${USER}
id -nG
sudo usermod -aG docker username

apt-get update && apt-get install -y apt-transport-https \
  && curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
apt-get update && apt-get install -y kubelet kubeadm kubernetes-cni

#kubeadm reset 


