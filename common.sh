app_user=roboshop

# function for echo statements
print_head(){
  echo -e "\e[35m>>>>>>>>>> $* <<<<<<<<<<\e[0m"

}

schema_setup(){
  echo -e "\e[36m>>>>>>>>>> copying mongoDB repo <<<<<<<<<<\e[0m"
  cp $script_path/mongo.repo /etc/yum.repos.d/mongo.repo

  echo -e "\e[36m>>>>>>>>>> Installing MongoDB Client <<<<<<<<<<\e[0m"
  yum install mongodb-org-shell -y

  echo -e "\e[36m>>>>>>>>>> Loading Schema Final <<<<<<<<<<\e[0m"
  mongo --host mongodb.devopsdude.cloud </app/schema/${component}.js
}

#cart function
func_nodejs(){

# If we want the input to be considered on we will use double quote "" and change the print head value from $* to $1
  print_head "Configuring NodeJS Repos"
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash

  print_head "Installing NodeJS"
  yum install nodejs -y

  print_head "Application user Added"
  useradd ${app_user}

  print_head "Creating Application Directory"
  rm -rf /app
  mkdir /app

  print_head "Downloading App Content"
  curl -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip
  cd /app

   print_head "Unzipping App Content"
  unzip /tmp/${component}.zip
  cd /app

   print_head "Installing NodeJS Dependencies"
  npm install

   print_head "Copying Service"
  cp $script_path/${component}.service /etc/systemd/system/${component}.service

   print_head "Starting cart Service"
  systemctl daemon-reload
  systemctl enable ${component}
  systemctl start ${component}

  schema_setup
}