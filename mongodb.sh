script=$(realpath "0")
script_path=$(dirname "$script")
source ${script_path}/common.sh

func_print_head "Setting Up MongoDB Repo"
cp $script_path/mongo.repo /etc/yum.repos.d/mongo.repo &>>$log_file
func_stat_check $?

func_print_head "Installing MongoDB"
yum install mongodb-org -y &>>$log_file
func_stat_check $?

func_print_head "Update MongoDB Listen Address"
sed -i -e 's|127.0.0.1|0.0.0.0|' /etc/mongod.conf &>>$log_file
func_stat_check $?

func_print_head "Start MongoD"
systemctl enable mongod &>>$log_file
systemctl start mongod &>>$log_file
func_stat_check $?