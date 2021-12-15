#!/bin/bash

#set -e

source Components/common.sh

yum install nginx -y &>>${LOG_FILE}
stat_check $? "Nginx installation"
curl -s -L -o /tmp/frontend.zip "https://github.com/roboshop-devops-project/frontend/archive/main.zip" &>>${LOG_FILE}
stat_check $? "Download frontend"

rm -rf /usr/share/nginx/html/*
stat_check $? "Remove old html pages"

cd /tmp && unzip /tmp/frontend.zip &>>${LOG_FILE}
stat_check $? "extracting frontend content"

cd /tmp/frontend-main/static/ && cp -r * /usr/share/nginx/html/
stat_check $? "copying frontend content"

cp /tmp/frontend-main/localhost.conf /etc/nginx/default.d/roboshop.conf
stat_check $? "Update Nginx config file"

systemctl enable nginx &>>${LOG_FILE} && systemctl restart nginx &>>${LOG_FILE}
stat_check $? "Restart Nginx"

