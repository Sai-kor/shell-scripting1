#!/bin/bash

##Mongodb setup
source Components/common.sh
curl -s -o /etc/yum.repos.d/mongodb.repo https://raw.githubusercontent.com/roboshop-devops-project/mongodb/main/mongo.repo &>>${LOG_FILE}
stat_check $? "Download mongodb repo"

yum install -y mongodb-org &>>${LOG_FILE}
stat_check $? "Install Mongodb"

sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf &>>${LOG_FILE}
stat_check $? "Update Mongodb service"

systemctl enable mongod &>>${LOG_FILE} && systemctl restart mongod &>>${LOG_FILE}
stat_check $? "Start MongoDB Service"

DOWNLOAD mongodb
 cd /tmp/mongodb-main
 mongo < catalogue.js &>>${LOG_FILE}&& mongo < users.js&>>${LOG_FILE}
 stat_check $? "Load Schema"