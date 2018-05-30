#su root

#run on master
su root
kubeadm reset
swapoff -a
kubeadm init --pod-network-cidr=10.244.0.0/16
sudo cp /etc/kubernetes/admin.conf $HOME/
sudo chown $(id -u):$(id -g) $HOME/admin.conf
export KUBECONFIG=$HOME/admin.conf

#run on master for every node
ssh_password=your_password
shpass -p "{$ssh_password}" scp /etc/kubernetes/admin.conf user@nodes.local: $HOME/


#run on every nodes
su root
kubeadm reset
swapoff -a
sudo chown $(id -u):$(id -g) $HOME/admin.conf
export KUBECONFIG=$HOME/admin.conf

#join cluster


