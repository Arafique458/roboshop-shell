script=$(realpath "0")
script_path=$(dirname "$script")
log_file=/tmp/roboshop.log
app_user=roboshop

# function for echo statements
func_print_head(){
  echo -e "\e[35m>>>>>>>>>> $* <<<<<<<<<<\e[0m"

}

func_stat_check(){
  if [ $1 -eq 0 ]; then
      echo -e "\e[32m>>> SUCCESS <<<\e[0m"
    else
      echo -e "\e[31m>>> FAILURE <<<\e[0m"
      echo "Refer the log files /tmp/roboshop.log for more information"
      exit 1
    fi

}

func_schema_setup(){

if [ "$schema_setup" == "mongo" ]; then
  func_print_head "copying mongoDB repo"
  cp $script_path/mongo.repo /etc/yum.repos.d/mongo.repo &>>$log_file
  func_stat_check $?

  func_print_head "Installing MongoDB Client"
  yum install mongodb-org-shell -y &>>$log_file
  func_stat_check $?

  func_print_head "Loading Schema Final "
  mongo --host mongodb.devopsdude.cloud </app/schema/${component}.js &>>$log_file
  func_stat_check $?
fi
if [ "$schema_setup" == "mysql" ]; then
  func_print_head "Installing MYSQL"
  yum install mysql -y &>>$log_file
  func_stat_check $?

  func_print_head "Loading Schema "
  mysql -h mysql.devopsdude.cloud -uroot -p${mysql_root_password} < /app/schema/shipping.sql &>>$log_file
  func_stat_check $?
fi
}


func_app_prereq(){
  func_print_head "Create Application User"
    id ${app_user} &>>$log_file #if user doesn't exit we add it using id
    if [ $? -ne 0 ]; then
      useradd ${app_user} &>>$log_file
    fi
    func_stat_check $?

    func_print_head "Creating Application Directory"
    rm -rf /app
    mkdir /app &>>$log_file
    func_stat_check $?

    func_print_head "Downloading Application Content"
    curl -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>>$log_file
    cd /app
    func_stat_check $?

    func_print_head "Unzipping Application Content"
    unzip /tmp/${component}.zip &>>$log_file
    func_stat_check $?
}

func_systemd_setup(){
    func_print_head "Copying Service"
    cp $script_path/${component}.service /etc/systemd/system/${component}.service &>>$log_file
    func_stat_check $?

    func_print_head "Starting ${component} Service"
    systemctl daemon-reload &>>$log_file
    systemctl enable ${component} &>>$log_file
    systemctl start ${component} &>>$log_file
    func_stat_check $?
}

#cart function
func_nodejs(){
# If we want the input to be considered on we will use double quote "" and change the print head value from $* to $1
  func_print_head "Configuring NodeJS Repos"
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>$log_file
  func_stat_check $?

  func_print_head "Installing NodeJS"
  yum install nodejs -y &>>$log_file
  func_stat_check $?

  func_app_prereq

  func_print_head "Installing NodeJS Dependencies"
  npm install &>>$log_file
  func_stat_check $?

  func_schema_setup
  func_systemd_setup

}

func_java(){
  func_print_head "Installing Maven"
  yum install maven -y &>>$log_file

  func_stat_check $? # ($#) Argument is being sent through here.

  func_app_prereq

  func_print_head "Downloading Maven Dependencies"
  mvn clean package &>>$log_file
  func_stat_check $?

  mv target/${component}-1.0.jar ${component}.jar &>>$log_file

  func_schema_setup
  func_systemd_setup
  }

func_python(){
  func_print_head "Installing Python"
  yum install python36 gcc python3-devel -y &>>$log_file
  func_stat_check $?

  func_app_prereq

  func_print_head "Installing Python Dependencies"
  pip3.6 install -r requirements.txt &>>$log_file
  func_stat_check $?

  func_print_head "Updating Passwords in System Service file"
  sed -i -e "s/rabbitmq_appuser_password |${rabbitmq_appuser_password}|" ${script_path}/payment.service &>>$log_file
  func_stat_check $?

  func_systemd_setup


}