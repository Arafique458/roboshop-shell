script=$(realpath "0")
script_path=$(dirname "$script")
source ${script_path}/common.sh
# defined in the common.sh as function
component=catalogue

func_nodejs

echo -e "\e[36m>>>>>>>>>> copying mongoDB repo <<<<<<<<<<\e[0m"
cp $script_path/mongo.repo /etc/yum.repos.d/mongo.repo

echo -e "\e[36m>>>>>>>>>> Installing MongoDB Client <<<<<<<<<<\e[0m"
yum install mongodb-org-shell -y

echo -e "\e[36m>>>>>>>>>> Restarting MongoDB Client <<<<<<<<<<\e[0m"
systemctl restart catalogue

echo -e "\e[36m>>>>>>>>>> Loading Schema Final <<<<<<<<<<\e[0m"
mongo --host mongodb-dev.devopsdude.cloud </app/schema/catalogue.js

