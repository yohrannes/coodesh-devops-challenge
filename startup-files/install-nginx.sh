#!/bin/bash
# Instalando nginx como proxy da porta 80 para a 5000 da aplicação.
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