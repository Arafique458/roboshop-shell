script=$(realpath "0")
script_path=$(dirname "$script")
source ${script_path}/common.sh
rabbitmq_appuser_password=$1

if [ -z "$rabbitmq_appuser_password" ]; then
  echo Input Roboshop Appuser Password Missing
  exit 1
fi

func_print_head "Installing MongoDB"
yum install mongodb-org -y &>>$log_file
func_stat_check $?

func_print_head "Setting Erlang repos"  
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>>$log_file
func_stat_check $?

func_print_head "Setting up RabbitMQ Repos"  
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>>$log_file
func_stat_check $?

func_print_head "Install Erlang & RabbitMQ"  
yum install erlang rabbitmq-server -y &>>$log_file
func_stat_check $?

func_print_head "Starting RabbitMQ Service"  
systemctl enable rabbitmq-server &>>$log_file
systemctl start rabbitmq-server &>>$log_file
func_stat_check $?

func_print_head "Adding Application user in RabbitMQ"  
rabbitmqctl add_user roboshop ${rabbitmq_appuser_password} &>>$log_file
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$log_file
func_stat_check $?
