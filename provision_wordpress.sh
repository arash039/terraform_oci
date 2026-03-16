#!/bin/bash

set -x

export DEBIAN_FRONTEND=noninteractive

sudo apt update -y
sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ubuntu
sudo apt install -y curl
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

if ! /usr/local/bin/docker-compose --version &> /dev/null; then
    echo "docker-compose installation failed"
    exit 1
fi

INSTANCE_PUBLIC_IP=$(curl -s https://ifconfig.me)
if [ -z "$INSTANCE_PUBLIC_IP" ]; then
    echo "Failed to fetch instance public IP. Exiting."
    exit 1
fi

mkdir -p wordpress
cd wordpress
cat <<EOF > docker-compose.yml
version: '3.3'
services:
  wordpress:
    image: wordpress:latest
    ports:
      - 8080:80
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_USER: exampleuser
      WORDPRESS_DB_PASSWORD: examplepass
      WORDPRESS_DB_NAME: exampledb
      WORDPRESS_SITE_URL: http://$INSTANCE_PUBLIC_IP:8080
      WORDPRESS_HOME: http://$INSTANCE_PUBLIC_IP:8080
  db:
    image: mysql:5.7
    environment:
      MYSQL_ROOT_PASSWORD: examplepass
      MYSQL_DATABASE: exampledb
      MYSQL_USER: exampleuser
      MYSQL_PASSWORD: examplepass
  caddy:
    image: caddy:latest
    ports:
      - 80:80
      - 443:443
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
    restart: unless-stopped
EOF

cat <<EOF > Caddyfile
{
    email you@example.com
}

$INSTANCE_PUBLIC_IP {
    reverse_proxy wordpress:80
}
EOF

cd wordpress
sudo docker-compose up -d

if [ $? -ne 0 ]; then
    echo "Docker Compose failed to start services"
    exit 1
fi

echo "Docker Compose services are up and running."

