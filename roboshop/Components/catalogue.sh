#!/bin/bash
source Components/common.sh

yum install nodejs make gcc-c++ -y &>>${LOG_FILE}
stat_check $? "Install nodejs"

id roboshop &>>${LOG_FILE}
if [ $? -ne 0 ]; then
 useradd roboshop &>>${LOG_FILE}
 stat_check $? "Add app user"
fi
DOWNLOAD catalogue

rm -rf /home/roboshop/catalogue && mkdir -p /home/roboshop/catalogue && cp -r /tmp/catalogue-main/* /home/roboshop/catalogue &>>${LOG_FILE}
stat_check $? "Copy catalogue content"

cd /home/roboshop/catalogue && npm install --unsafe-perm &>>${LOG_FILE}
stat_check $? "Install Nodejs dependencies"

chown roboshop:roboshop -R /home/roboshop

sed -i -e 's/MONGO_DNSNAME/mongodb.devops.internal/' /home/roboshop/catalogue/systemd.service &>>${LOG_FILE} && mv /home/roboshop/catalogue/systemd.service /etc/systemd/system/catalogue.service &>>${LOG_FILE}
stat_check $? "update systemd config file"

systemctl daemon-reload&>>${LOG_FILE} && systemctl start catalogue&>>${LOG_FILE} && systemctl enable catalogue&>>${LOG_FILE}
stat_check $? "Start catalogue service"

