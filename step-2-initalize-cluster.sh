#su root

#run on master
su root
kubeadm reset
swapoff -a
kubeadm init --pod-network-cidr=10.244.0.0/16
sudo cp /etc/kubernetes/admin.conf $HOME/
sudo chown $(id -u):$(id -g) $HOME/admin.conf
export KUBECONFIG=$HOME/admin.conf

ssh_password=auto63906
node_host=upb-2.local
user=autolab
rm ./k8s-config-setting.sh
touch ./k8s-config-setting.sh
cat <<EOF | sudo tee ./k8s-config-setting.sh
kubeadm reset
swapoff -a
sudo cp /home/$user/admin.conf \$HOME/
sudo chown \$(id -u):\$(id -g) \$HOME/admin.conf
export KUBECONFIG=$HOME/admin.conf

EOF
#run on master for every node
sshpass -p "$ssh_password" scp /etc/kubernetes/admin.conf $user@$node_host:/home/$user/
sshpass -p "$ssh_password" scp ./k8s-config-setting.sh $user@$node_host:/home/$user/

#run on every nodes
#login the user you use in line 14 
cd $HOME
su root 
sh ./k8s-config-setting.sh

#join cluster


