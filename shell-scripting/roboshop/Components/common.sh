#!/bin/bash

LOG_FILE=/tmp/roboshop.log
rm -f ${LOG_FILE}

stat_check(){
if [ "${1}" -ne 0 ]; then
 echo -e "\e[1m${2} - \e[1;31mFAILED\e[0m"
 exit 1
 else
   echo -e "\e[1m${2} -\e[1;32mSUCCESS\e[0m"
fi

}

set-hostname -skip-apply ${component}
SYSTEMD_SETUP(){
   chown roboshop:roboshop -R /home/roboshop
    sed -i -e 's/MONGO_DNSNAME/mongodb.devops.internal/' \
    -e 's/REDIS_ENDPOINT/redis.devops.internal/' \
    -e 's/MONGO_ENDPOINT/mongodb.devops.internal/' \
    -e 's/CATALOGUE_ENDPOINT/catalogue.devops.internal/' \
    -e 's/CARTENDPOINT/cart.devops.internal/' \
    -e 's/DBHOST/mysql.devops.internal/' \
    -e 's/CARTHOST/cart.devops.internal/' \
    -e 's/USERHOST/user.devops.internal/' \
    -e 's/AMQPHOST/rabbitmq.devops.internal/' \
    -e 's/RABBITMQ-IP/rabbitmq.devops.internal/' \
     /home/roboshop/${COMPONENT}/systemd.service &>>${LOG_FILE} && mv /home/roboshop/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service &>>${LOG_FILE}
    stat_check $? "update systemd config file"

    systemctl daemon-reload &>>${LOG_FILE} && systemctl restart ${COMPONENT}&>>${LOG_FILE} && systemctl enable ${COMPONENT}&>>${LOG_FILE}
    stat_check $? "Start ${COMPONENT} service"
}
APP_USER_SETUP(){
    id roboshop &>>${LOG_FILE}
    if [ $? -ne 0 ]; then
     useradd roboshop &>>${LOG_FILE}
     stat_check $? "Add app user"
    fi
    DOWNLOAD ${COMPONENT}

}

DOWNLOAD(){
  curl -s -L -o /tmp/${1}.zip "https://github.com/roboshop-devops-project/${1}/archive/main.zip" &>>${LOG_FILE}
  stat_check $? "Download ${1} code"
  cd /tmp
  unzip -o /tmp/${1}.zip&>>${LOG_FILE}
  stat_check $? "Extracting ${1} code"
  if [ ! -z "${COMPONENT}" ]; then
      rm -rf /home/roboshop/${COMPONENT} && mkdir -p /home/roboshop/${COMPONENT} && cp -r /tmp/${COMPONENT}-main/* /home/roboshop/${COMPONENT} &>>${LOG_FILE}
      stat_check $? "Copy ${COMPONENT} content"
  fi
}

NODEJS(){
  COMPONENT=${1}
  yum install nodejs make gcc-c++ -y &>>${LOG_FILE}
  stat_check $? "Install nodejs"
 APP_USER_SETUP

  cd /home/roboshop/${COMPONENT} && npm install --unsafe-perm &>>${LOG_FILE}
  stat_check $? "Install Nodejs dependencies"

  SYSTEMD_SETUP
}

JAVA(){
  COMPONENT=${1}
  yum install maven -y &>>${LOG_FILE}
  stat_check $? "Install Maven"

   APP_USER_SETUP
  cd /home/roboshop/${COMPONENT} && mvn clean package &>>${LOG_FILE} && mv target/${COMPONENT}-1.0.jar ${COMPONENT}.jar &>>${LOG_FILE}
  stat_check $? "Compile Java Code"

SYSTEMD_SETUP
}

PYTHON(){
  COMPONENT=${1}
  yum install python36 gcc python3-devel -y &>>${LOG_FILE}
  stat_check $? "Installing python"

  APP_USER_SETUP

  cd /home/roboshop/${COMPONENT} && pip3 install -r requirements.txt &>>${LOG_FILE}
  stat_check $? "Instal python dependencies"


 # Update the roboshop user and group id in payment.ini file.

 # Setup the service
SYSTEMD_SETUP
}

GOLANG(){
  COMPONENT=${1}

  yum install golang -y &>>${LOG_FILE}
  stat_check $? "Installing golang"

  APP_USER_SETUP

  cd /home/roboshop/${COMPONENT} && go mod init dispatch &>>${LOG_FILE} && go get &>>${LOG_FILE} && go build &>>${LOG_FILE}
  stat_check $? "Install golang dependencies and compile"

SYSTEMD_SETUP
}