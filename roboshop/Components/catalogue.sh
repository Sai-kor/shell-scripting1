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

rm -rf /home/roboshop/catalogue && mkdir -p /home/roboshop/catalogue && cp -r /tmp/catalogue-main/* /home/roboshop/catalogue &>>{LOG_FILE}
stat_check $? "Copy catalogue content"

cd /home/roboshop/catalogue && npm install --unsafe-perm &>>{LOG_FILE}
stat_check $? "Install Nodejs dependencies"
#$ mv catalogue-main catalogue
#$ cd /home/roboshop/catalogue
#$ npm install
#NOTE: We need to update the IP address of MONGODB Server in systemd.service file
#Now, lets set up the service with systemctl.

# mv /home/roboshop/catalogue/systemd.service /etc/systemd/system/catalogue.service
# systemctl daemon-reload
# systemctl start catalogue
# systemctl enable catalogue

