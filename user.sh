script_path=$(dirname $0)
source ${script_path}/common.sh

echo -e "\e[36m>>>>>>>>>> Configuring NodeJS Repos <<<<<<<<<<\e[0m"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash

echo -e "\e[36m>>>>>>>>>> Installing NodeJS <<<<<<<<<<\e[0m"
yum install nodejs -y

echo -e "\e[36m>>>>>>>>>> Application user Added <<<<<<<<<<\e[0m"
useradd ${app_user}

echo -e "\e[36m>>>>>>>>>> Creating Application Directory <<<<<<<<<<\e[0m"
rm -rf /app
mkdir /app

echo -e "\e[36m>>>>>>>>>> Downloading App Content <<<<<<<<<<\e[0m"
curl -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user.zip
cd /app

echo -e "\e[36m>>>>>>>>>> Unzipping App Content <<<<<<<<<<\e[0m"
unzip /tmp/user.zip
cd /app

echo -e "\e[36m>>>>>>>>>> Installing NodeJS Dependencies <<<<<<<<<<\e[0m"
npm install

echo -e "\e[36m>>>>>>>>>> Coping service <<<<<<<<<<\e[0m"
cp /root/roboshop-shell/user.service /etc/systemd/system/user.service

echo -e "\e[36m>>>>>>>>>> Starting User Service <<<<<<<<<<\e[0m"
systemctl daemon-reload
systemctl enable user
systemctl start user

echo -e "\e[36m>>>>>>>>>> copying mongoDB repo <<<<<<<<<<\e[0m"
cp $script_path/mongo.repo /etc/yum.repos.d/mongo.repo

echo -e "\e[36m>>>>>>>>>> Installing MongoDB Client <<<<<<<<<<\e[0m"
yum install mongodb-org-shell -y

echo -e "\e[36m>>>>>>>>>> Restarting MongoDB Client <<<<<<<<<<\e[0m"
systemctl restart user

echo -e "\e[36m>>>>>>>>>> Loading Schema Final <<<<<<<<<<\e[0m"
mongo --host mongodb.devopsdude.cloud </app/schema/user.js