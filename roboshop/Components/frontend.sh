#!/bin/bash

#set -e
# yum install nginx -y
# systemctl enable nginx
# systemctl start nginx
#Let's download the HTML content that serves the RoboSHop Project UI and deploy under the Nginx path.

# curl -s -L -o /tmp/frontend.zip "https://github.com/roboshop-devops-project/frontend/archive/main.zip"
#Deploy in Nginx Default Location.

# cd /usr/share/nginx/html
# rm -rf *
# unzip /tmp/frontend.zip
# mv frontend-main/* .
# mv static/* .
# rm -rf frontend-master static README.md
# mv localhost.conf /etc/nginx/default.d/roboshop.conf
#Finally restart the service once to effect the changes.

# systemctl restart nginx
#echo frontend setup
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
yum install nginx -y &>>${LOG_FILE}
stat_check $? "Nginx installation"
curl -s -L -o /tmp/frontend.zip "https://github.com/roboshop-devops-project/frontend/archive/main.zip" &>>${LOG_FILE}
stat_check $? "Download frontend"

rm -rf /usr/share/nginx/html/*
stat_check $? "Remove old html pages"
if [ -f "/tmp/frontend-main/" ]; then
  {
    rm -rf /tmp/frontend-main
  }
  fi
cd /tmp && unzip /tmp/frontend.zip &>>${LOG_FILE}
stat_check $? "extracting frontend content"

cd /tmp/frontend-main/static/ && cp -r * /usr/share/nginx/html/
stat_check $? "copying frontend content"

cp /tmp/frontend-main/localhost.conf /etc/nginx/default.d/roboshop.conf
stat_check $? "Update Nginx config file"

systemctl enable nginx &>>${LOG_FILE} && systemctl start nginx &>>${LOG_FILE}
#systemctl restart nginx
