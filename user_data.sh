
#!/bin/bash
# Instalar Docker-CE ( Container Engine):
sudo yum update
sudo yum upgrade
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
# EFS
#Instalar, iniciar e configurar a inicialização automática do nfs-utils
sudo yum install nfs-utils -y
sudo systemctl start nfs-utils.service
sudo systemctl enable nfs-utils.service
#para montar arquivo efs:
mkdir -p /home/ec2-user/efs/efs-mount-point
# Montar o sistema de arquivo
sudo mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-0d89c492d6d236cb5.efs.us-east-1.amazonaws.com:/   /home/ec2-user/efs/efs-mount-point
# Montagem automática
sudo echo "fs-0d89c492d6d236cb5.efs.us-east-1.amazonaws.com:/ /home/ec2-user/efs/efs-mount-point  nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0" | sudo tee -a /etc/fstab
# Instalar Docker Compose:
sudo curl -SL https://github.com/docker/compose/releases/download/v2.19.1/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
# Cria o docker-compose.yaml
sudo mkdir /home/ec2-user/docker-compose
# Define o conteúdo do docker-compose.yml
sudo tee /home/ec2-user/docker-compose/docker-compose.yml >/dev/null <<EOF
version: "3.1"
services:
  wordpress:
    image: wordpress:latest      
    restart: always
    ports:
      - 80:80
    environment:
      WORDPRESS_DB_HOST: rdswp.ct44e0mo48d8.us-east-1.rds.amazonaws.com
      WORDPRESS_DB_USER: admin
      WORDPRESS_DB_PASSWORD: 12345678
      WORDPRESS_DB_NAME: db_wordpress
    volumes:
      - /home/ec2-user/efs/efs-mount-point:/var/www/html
EOF
# Remove linhas em branco do arquivo docker-compose.yml
sudo sed -i '/^$/d' /home/ec2-user/docker-compose/docker-compose.yml
# Inicia containers
cd /home/ec2-user/docker-compose/
docker-compose up -d

