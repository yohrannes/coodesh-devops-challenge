#!/bin/bash

function install-docker-engine () {
echo "Instalando docker engine e executando a aplicação em container."
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable docker
sudo systemctl start docker
sudo docker run -d -p 5000:5000 yohrannes/coodesh-challenge
sudo bash startup-files/install-nginx.sh
}
function install-nginx () {
echo  "Instalando nginx como proxy da porta 80 para a 5000 da aplicação."
sudo apt-get install -y nginx
sudo tee /etc/nginx/sites-available/default <<EOF
server {
listen 80;
server_name _;

location / {
    proxy_pass http://localhost:5000;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
}
}
EOF
sudo systemctl restart nginx
sudo systemctl enable nginx
}

if [[ $1 == "install-nginx" ]]; then
    install-nginx
else
    install-docker-engine
    install-nginx
fi
