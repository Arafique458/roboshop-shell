curl -sL https://rpm.nodesource.com/setup_lts.x | bash
yum install nodejs -y
useradd roboshop
mkdir /app
curl -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user.zip
cd /app
unzip /tmp/user.zip
cd /app
npm install
cp catalogue.service /etc/systemd/system/catalogue.service
systemctl daemon-reload
systemctl enable user
systemctl start user

cp mongo.repo /etc/yum.repos.d/mongo.repo
yum install mongo-org-shell -y
mongo --host mongodb.devopsdude.cloud </app/schema/catalogue.js