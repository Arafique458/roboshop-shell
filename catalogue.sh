echo "\e[36m>>>>>>>>>> Configuring NodeJS Repos<<<<<<<<<<\e[0m"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash

echo "\e[36m>>>>>>>>>> Installing Nodejs <<<<<<<<<<\e[0m"
yum install nodejs -y

echo "\e[36m>>>>>>>>>> Adding Application User <<<<<<<<<<\e[0m"
useradd roboshop

echo "\e[36m>>>>>>>>>> Creating Directory <<<<<<<<<<\e[0m"
rm -rf /app
mkdir /app

echo "\e[36m>>>>>>>>>> Downloading App content <<<<<<<<<<\e[0m"
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip
cd /app

echo "\e[36m>>>>>>>>>> unziping app content <<<<<<<<<<\e[0m"
unzip /tmp/catalogue.zip
cd /app

echo "\e[36m>>>>>>>>>> Installing NodeJS Dependencies <<<<<<<<<<\e[0m"
npm install

echo "\e[36m>>>>>>>>>> coping catalogue systemd file <<<<<<<<<<\e[0m"
cp catalogue.service /etc/systemd/system/catalogue.service

echo "\e[36m>>>>>>>>>> Starting Catalogue service <<<<<<<<<<\e[0m"
systemctl daemon-reload
systemctl enable catalogue
systemctl start catalogue

echo "\e[36m>>>>>>>>>> copying mongoDB repo <<<<<<<<<<\e[0m"
cp mongo.repo /etc/yum.repos.d/mongo.repo

echo "\e[36m>>>>>>>>>> Installing MongoDB Client <<<<<<<<<<\e[0m"
yum install mongo-org-shell -y

echo "\e[36m>>>>>>>>>> Loading Schema Final <<<<<<<<<<\e[0m"
mongo --host mongodb.devopsdude.cloud </app/schema/catalogue.js