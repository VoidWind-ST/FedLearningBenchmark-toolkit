#!/bin/bash
# Public address
CONTROLLER_URL="http://52.87.161.67"
# Retrieve the local IPv4 address of the current EC2 instance from the AWS EC2 Metadata Service by sending an HTTP request.
#SERVER_IP=`curl http://169.254.169.254/latest/meta-data/local-ipv4`    # This is not working, return 401 Unauthorized error
SERVER_IP="172.31.80.91"    # try this, got it from AWS EC2 Private IPv4 addresses
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.0/node_exporter-1.6.0.linux-amd64.tar.gz
tar xvfz node_exporter-*.*-amd64.tar.gz
rm xvfz node_exporter-*.*-amd64.tar.gz      #New added
cd node_exporter-*.*-amd64
nohup ./node_exporter &
cd ..

sudo apt update && sudo apt install zip g++ cmake -y
mkdir flbenchmark.working
cd flbenchmark.working
wget $CONTROLLER_URL/files/flb-data.zip             # what is this for? # fixed, should be
unzip flb-data.zip                                  # nothing to open # fixed, should be
cd ..

# CoLink, unified interface for big decentralized  data
mkdir server
cd server
wget https://github.com/CoLearn-Dev/colink-server-dev/releases/download/v0.3.6/colink-server-linux-x86_64.tar.gz
tar -xzf colink-server-linux-x86_64.tar.gz
rm colink-server-linux-x86_64.tar.gz
# during this execution of the program, permanently set the ./colink-server capable to bind ports below 1024
sudo setcap CAP_NET_BIND_SERVICE=+ep ./colink-server
echo "Install colink-server: done"

mkdir init_state
cd init_state
#wget $CONTROLLER_URL/jwt_secret.txt         # 404 not found # fixed
#wget $CONTROLLER_URL/priv_key.txt           # 404 not found # fixed
wget $CONTROLLER_URL/files/jwt_secret.txt         # changed
wget $CONTROLLER_URL/files/priv_key.txt           # changed 
cd ..

# RabbitMQ is an open-source message-broker, to build distributed application
sudo apt update && sudo apt install rabbitmq-server -y
sudo rabbitmq-plugins enable rabbitmq_management
sudo service rabbitmq-server restart

# get anaconda
#wget https://repo.anaconda.com/archive/Anaconda3-2023.03-1-Linux-x86_64.sh
#bash Anaconda3-2023.03-1-Linux-x86_64.sh -b
#rm Anaconda3-2023.03-1-Linux-x86_64.sh

# docker, OS-level virtualization
wget https://get.docker.com -O get-docker.sh
sudo bash get-docker.sh
sudo usermod -aG docker ubuntu


export BASH_ENV="$HOME/anaconda3/etc/profile.d/conda.sh"
export COLINK_VT_PUBLIC_ADDR="$SERVER_IP"

nohup ./colink-server --address 0.0.0.0 --port 80 --mq-uri amqp://guest:guest@$SERVER_IP:5672 --mq-api http://guest:guest@localhost:15672/api --mq-prefix colink-test-server --core-uri http://$SERVER_IP:80 --pom-allow-external-source > output.log 2>&1 &

curl $CONTROLLER_URL/report_ip.php?ip=$SERVER_IP
