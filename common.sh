app_user=roboshop

#cart function
func_nodejs(){
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash

  echo -e "\e[36m>>>>>>>>>> Installing NodeJS <<<<<<<<<<\e[0m"
  yum install nodejs -y

  echo -e "\e[36m>>>>>>>>>> Application user Added <<<<<<<<<<\e[0m"
  useradd ${app_user}

  echo -e "\e[36m>>>>>>>>>> Creating Application Directory <<<<<<<<<<\e[0m"
  rm -rf /app
  mkdir /app

  echo -e "\e[36m>>>>>>>>>> Downloading App Content <<<<<<<<<<\e[0m"
  curl -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip
  cd /app

  echo -e "\e[36m>>>>>>>>>> Unzipping App Content <<<<<<<<<<\e[0m"
  unzip /tmp/${component}.zip
  cd /app

  echo -e "\e[36m>>>>>>>>>> Installing NodeJS Dependencies <<<<<<<<<<\e[0m"
  npm install

  echo -e "\e[36m>>>>>>>>>> Coping service <<<<<<<<<<\e[0m"
  cp $script_path/${component}.service /etc/systemd/system/${component}.service

  echo -e "\e[36m>>>>>>>>>> Starting cart Service <<<<<<<<<<\e[0m"
  systemctl daemon-reload
  systemctl enable ${component}
  systemctl start ${component}
}