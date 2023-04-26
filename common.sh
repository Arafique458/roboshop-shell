app_user=roboshop

# function for echo statements
func_print_head(){
  echo -e "\e[35m>>>>>>>>>> $* <<<<<<<<<<\e[0m"

}

func_stat_check(){
  if [ $? -eq 0 ]; then
      echo -e "\e[32m>>> SUCCESS <<<\e[0m"
    else
      echo echo -e "\e[31m>>> FAILURE <<<\e[0m"
    fi

}

func_schema_setup(){

if [ "$schema_setup" == "mongo" ]; then
  func_print_head "copying mongoDB repo"
  cp $script_path/mongo.repo /etc/yum.repos.d/mongo.repo

  func_print_head "Installing MongoDB Client"
  yum install mongodb-org-shell -y

  func_print_head "Loading Schema Final "
  mongo --host mongodb.devopsdude.cloud </app/schema/${component}.js
fi
if [ "$schema_setup" == "mysql" ]; then

  func_print_head "Installing MYSQL"
  yum install mysql -y

  func_print_head "Loading Schema "
  mysql -h mysql.devopsdude.cloud -uroot -p${mysql_root_password} < /app/schema/shipping.sql
fi
}


func_app_prereq(){
  func_print_head "Create Application User"
    useradd ${app_user}

    func_print_head "Creating Application Directory"
    rm -rf /app
    mkdir /app

    func_print_head "Downloading Application Content"
    curl -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip
    cd /app

     func_print_head "Unzipping Application Content"
    unzip /tmp/${component}.zip
}

func_systemd_setup(){
  func_print_head "Copying Service"
    cp $script_path/${component}.service /etc/systemd/system/${component}.service

     func_print_head "Starting ${component} Service"
    systemctl daemon-reload
    systemctl enable ${component}
    systemctl start ${component}
}

#cart function
func_nodejs(){
# If we want the input to be considered on we will use double quote "" and change the print head value from $* to $1
  func_print_head "Configuring NodeJS Repos"
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash

  func_print_head "Installing NodeJS"
  yum install nodejs -y

  func_app_prereq

  func_print_head "Installing NodeJS Dependencies"
  npm install

  func_schema_setup
  func_systemd_setup

}

func_java(){
  func_print_head "Installing Maven"
  yum install maven -y

  func_stat_check $? # ($#) Argument is being sent through here.

  func_app_prereq

  func_print_head "Downloading Maven Dependencies"
  mvn clean package

  func_stat_check $?

  mv target/${component}-1.0.jar ${component}.jar

  func_schema_setup
  func_systemd_setup
  }