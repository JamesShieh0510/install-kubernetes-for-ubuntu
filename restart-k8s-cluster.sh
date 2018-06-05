
#重新啟動master，請在master machine上執行此script
#特別注意此script須先將ssh root登入權限打開，才能正常使用
#如果你還沒設定，請編輯 /etc/ssh/sshd_config"
#將以下script註解：PermitRootLogin without-password"
#並在其後，將以下script加入：PermitRootLogin yes"
#重新啟動ssh，請執行以下指令 :service ssh reload"

#請以root執行此script:
#su root
#請將下列變數改成你的cluster環境

# 每個node的user
node_root_users=( "user1" "user2" )
# 每個node的hostname
node_hosts=( "upb-2.local" "192.168.0.107" )
# 每個node的執行目錄
node_path=( "/home/autolab/" "/home/autolab/" )
# 每個node的user密碼
node_passwd=( "pswd1" "pawd2" )

len=${#node_hosts[*]}  # it returns the array length

#初始化 kubernetes master
sudo kubeadm reset
sudo swapoff -a
sudo kubeadm init --pod-network-cidr=10.244.0.0/16


#取得cluster token與ca cert hash
token=$(kubeadm token create)
token_ca_cert_hash=$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //')
default_ip=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')

#取得使用者設定資訊	
sudo cp /etc/kubernetes/admin.conf $HOME/
sudo chown $(id -u):$(id -g) $HOME/admin.conf
export KUBECONFIG=$HOME/admin.conf

#建立pods network
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/k8s-manifests/kube-flannel-rbac.yml
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml


#建立shell script
#此shell script用來初始化每個node，並將其加入cluster中
rm ./join-cluster-for-every-nodes.sh
touch ./join-cluster-for-every-nodes.sh
cat <<EOF | sudo tee ./join-cluster-for-every-nodes.sh
#su root
sudo kubeadm reset
sudo swapoff -a
sudo kubeadm join $default_ip:6443 --token $token --discovery-token-ca-cert-hash sha256:$token_ca_cert_hash
sudo cp /etc/kubernetes/admin.conf $HOME/
sudo chown $(id -u):$(id -g) $HOME/admin.conf
export KUBECONFIG=$HOME/admin.conf
EOF

#將每個node加入cluster中
for (( i=0; i<len; i++ ))    
do
    echo Node: ${node_hosts[$i]} Users: ${node_root_users[$i]} 
    sudo sshpass -p${node_passwd[$i]} scp ./join-cluster-for-every-nodes.sh ${node_root_users[$i]}@${node_hosts[$i]}:${node_path[$i]}
    echo "join cluster..."
    #sudo shpass -p ${node_passwd[$i]} 
    ssh ${node_hosts[$i]} "echo ${node_passwd[$i]} | sudo -S sh ${node_path[$i]}join-cluster-for-every-nodes.sh"
    #sshpass -p${node_passwd[$i]} ssh -o StrictHostKeyChecking=no ${node_root_users[$i]}@${node_hosts[$i]} sudo sh ${node_path[$i]}join-cluster-for-every-nodes.sh
done

#sudo bash ./restart-k8s-cluster.sh

