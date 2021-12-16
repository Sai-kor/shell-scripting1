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

DOWNLOAD(){
  curl -s -L -o /tmp/${1}.zip "https://github.com/roboshop-devops-project/${1}/archive/main.zip" &>>${LOG_FILE}
  stat_check $? "Download ${1} code"
  cd /tmp
  unzip -o /tmp/${1}.zip&>>${LOG_FILE}
  stat_check $? "Extracting ${1} code"
}

NODEJS(){
  COMPONENT=${1}
  yum install nodejs make gcc-c++ -y &>>${LOG_FILE}
  stat_check $? "Install nodejs"

  id roboshop &>>${LOG_FILE}
  if [ $? -ne 0 ]; then
   useradd roboshop &>>${LOG_FILE}
   stat_check $? "Add app user"
  fi
  DOWNLOAD ${COMPONENT}

  rm -rf /home/roboshop/${COMPONENT} && mkdir -p /home/roboshop/${COMPONENT} && cp -r /tmp/${COMPONENT}-main/* /home/roboshop/${COMPONENT} &>>${LOG_FILE}
  stat_check $? "Copy ${COMPONENT} content"

  cd /home/roboshop/${COMPONENT} && npm install --unsafe-perm &>>${LOG_FILE}
  stat_check $? "Install Nodejs dependencies"

  chown roboshop:roboshop -R /home/roboshop

  sed -i -e 's/MONGO_DNSNAME/mongodb.devops.internal/' /home/roboshop/${COMPONENT}/systemd.service &>>${LOG_FILE} && mv /home/roboshop/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service &>>${LOG_FILE}
  stat_check $? "update systemd config file"

  systemctl daemon-reload&>>${LOG_FILE} && systemctl start ${COMPONENT}&>>${LOG_FILE} && systemctl enable ${COMPONENT}&>>${LOG_FILE}
  stat_check $? "Start ${COMPONENT} service"
}


