script=$(realpath "0")
script_path=$(dirname "$script")
source ${script_path}/common.sh
mysql_root_password=$1

echo -e "\e[36m>>>>>>>>>> Installing Maven <<<<<<<<<<\e[0m"
yum install maven -y

echo -e "\e[36m>>>>>>>>>> Adding user <<<<<<<<<<\e[0m"
useradd ${app_user}

echo -e "\e[36m>>>>>>>>>> Creating Application Directory <<<<<<<<<<\e[0m"
rm -rf /app
mkdir /app

echo -e "\e[36m>>>>>>>>>> Extract App Content <<<<<<<<<<\e[0m"
curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping.zip
cd /app
unzip /tmp/shipping.zip

echo -e "\e[36m>>>>>>>>>> Downloading Maven Dependencies <<<<<<<<<<\e[0m"
mvn clean package
mv target/shipping-1.0.jar shipping.jar

echo -e "\e[36m>>>>>>>>>> Installing MYSQL <<<<<<<<<<\e[0m"
yum install mysql -y

echo -e "\e[36m>>>>>>>>>> Loading Schema <<<<<<<<<<\e[0m"
mysql -h mysql.devopsdude.cloud -uroot -p${mysql_root_password} < /app/schema/shipping.sql

echo -e "\e[36m>>>>>>>>>> Setting up Systemd Service <<<<<<<<<<\e[0m"
cp $script_path/shipping.service /etc/systemd/system/shipping.service

echo -e "\e[36m>>>>>>>>>> Restarting Shipping <<<<<<<<<<\e[0m"
systemctl daemon-reload
systemctl enable shipping
systemctl restart shipping