#!/bin/bash

if [ -z $SUDO_USER ]
then
    echo "===== Script need to be executed with sudo ===="
    echo "Change directory to 'network/setup'"
    echo "Usage: sudo ./docker.sh"
    exit 0
fi

export DOCKER_VERSION=18.03

install_docker() {
    apt-get update
    # curl -sSL https://get.daocloud.io/docker | sh
    curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
    echo "======= Adding docker registry======="
    echo '{"registry-mirrors":["https://hub-mirror.c.163.com/"]}' | sudo tee /etc/docker/daemon.json 
    # usermod -aG docker vagrant
    echo "======= Adding $SUDO_USER to the docker group ======="
    usermod -aG docker $SUDO_USER
}



# Install docker
install_docker

service docker restart
systemctl daemon-reload
systemctl restart docker

echo "======= Done. PLEASE LOG OUT & LOG Back In ===="
echo "Then validate by executing    'docker info'"

