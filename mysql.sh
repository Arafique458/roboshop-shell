script=$(realpath "0")
script_path=$(dirname "$script")
source ${script_path}/common.sh
mysql_root_password=$1

if [ -z "$rabbitmq_appuser_password"]; then
  echo RabbitMQ App user Password is Missing
fi

echo -e "\e[36m>>>>>>>>>> Disabling MYSQL 8 Version <<<<<<<<<<\e[0m"
dnf module disable mysql -y

echo -e "\e[36m>>>>>>>>>> Copying MySQL Repo File <<<<<<<<<<\e[0m"
cp $script_path/mysql.repo /etc/yum.repos.d/mysql.repo

echo -e "\e[36m>>>>>>>>>> Install MySQL <<<<<<<<<<\e[0m"
yum install mysql-community-server -y

echo -e "\e[36m>>>>>>>>>> Starting MYSQL <<<<<<<<<<\e[0m"
systemctl enable mysqld
systemctl start mysqld

echo -e "\e[36m>>>>>>>>>> Reseting MYSQL Password <<<<<<<<<<\e[0m"
mysql_secure_installation --set-root-pass $mysql_root_password
mysql -uroot -pRoboShop@1
