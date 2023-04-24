script_path=$(dirname $0)
source ${script_path}/common.sh

echo -e "\e[36m>>>>>>>>>> Installing Python <<<<<<<<<<\e[0m"
yum install python36 gcc python3-devel -y

echo -e "\e[36m>>>>>>>>>> Adding Application user <<<<<<<<<<\e[0m"
useradd ${app_user}

echo -e "\e[36m>>>>>>>>>> Creating Application Directory <<<<<<<<<<\e[0m"
rmdir -rf /app
mkdir /app

echo -e "\e[36m>>>>>>>>>> Downloading Payment Zip <<<<<<<<<<\e[0m"
curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment.zip
cd /app

echo -e "\e[36m>>>>>>>>>> Extracting the files <<<<<<<<<<\e[0m"
unzip /tmp/payment.zip
cd /app

echo -e "\e[36m>>>>>>>>>> Installing Python Dependencies <<<<<<<<<<\e[0m"
pip3.6 install -r requirements.txt

echo -e "\e[36m>>>>>>>>>> Setting up Systemd Service <<<<<<<<<<\e[0m"
cp $script_path/payment.service /etc/systemd/system/payment.service

echo -e "\e[36m>>>>>>>>>> Starting the Payment Service <<<<<<<<<<\e[0m"
systemctl daemon-reload
systemctl enable payment
systemctl start payment
