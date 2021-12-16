#!/bin/bash
source Components/common.sh

yum install nodejs make gcc-c++ -y &>>${LOG_FILE}
stat_check $? "Install nodejs"

useradd roboshop &>>${LOG_FILE}
stat_check $? "Add app user"
DOWNLOAD catalogue
#$ mv catalogue-main catalogue
#$ cd /home/roboshop/catalogue
#$ npm install
#NOTE: We need to update the IP address of MONGODB Server in systemd.service file
#Now, lets set up the service with systemctl.

# mv /home/roboshop/catalogue/systemd.service /etc/systemd/system/catalogue.service
# systemctl daemon-reload
# systemctl start catalogue
# systemctl enable catalogue

