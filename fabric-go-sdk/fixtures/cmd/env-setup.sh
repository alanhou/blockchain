# Golang installation
echo "##########   installing golang  ##########"
sudo apt install wget -y
wget https://golang.google.cn/dl/go1.15.11.linux-amd64.tar.gz 
sudo tar -C /usr/local -xzf go1.15.11.linux-amd64.tar.gz 
# environment variable
export PATH=$PATH:/usr/local/go/bin 
# go proxy
go env -w GO111MODULE=on 
go env -w GOPROXY=https://goproxy.cn,direct

# Docker installation
echo "##########   installing docker  ##########"
curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
echo '{"registry-mirrors":["https://hub-mirror.c.163.com/"]}' | sudo tee /etc/docker/daemon.json 

# docker-compose
echo "##########   installing docker compose  ##########"
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose 
sudo chmod +x /usr/local/bin/docker-compose

sudo usermod -aG docker $USER
sudo systemctl restart docker
# sudo systemctl enable docker

echo "##########   downloading hyperledger fabric  ##########"
cd $HOME
curl -sSL https://raw.githubusercontent.com/hyperledger/fabric/master/scripts/bootstrap.sh | bash -s 
export PATH=${HOME}/fabric-samples/bin:$PATH 

echo "##########   log out and log back in  ##########"
