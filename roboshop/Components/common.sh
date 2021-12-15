#!/bin/bash

LOG_FILE=/tmp/roboshop.log
rm -f ${LOG_FILE}

stat_check(){
if [ "${1}" -ne 0 ]; then
 echo -e "\e[1;31m${2} -- FAILED\e[0m"
 exit 1
 else
   echo -e "\e[1;32m${2} --SUCCESS\e[0m"
fi

}

set-hostname -skip-apply ${component}

DOWNLOAD(){
  curl -s -L -o /tmp/${1}.zip "https://github.com/roboshop-devops-project/${1}/archive/main.zip" &>>${LOG_FILE}
  stat_check $? "Download ${1} code"
  cd /tmp
  unzip -o /tmp/{1}.zip&>>${LOG_FILE}
  stat_check $? "Extracting ${1} code"
}