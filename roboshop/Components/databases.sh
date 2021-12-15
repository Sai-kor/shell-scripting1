#!/bin/bash

##Mongodb setup
echo -e "                -------->>>>>> \e[1;35mMongoDB Setup\e[0m  <<<<<<-------------"
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

 ##Redis setup
 echo -e "                -------->>>>>> \e[1;35mRedis Setup\e[0m  <<<<<<-------------"
 curl -L https://raw.githubusercontent.com/roboshop-devops-project/redis/main/redis.repo -o /etc/yum.repos.d/redis.repo &>>{LOG_FILE}
  stat_check $? "Download Redis Repo"

  yum install redis -y &>>{LOG_FILE}
  stat_check $? "Install redis"

  sed -i 's/127.0.0.1/0.0.0.0/' /etc/redis.conf &>>{LOG_FILE}
  stat_check $? "update redis config file"
 #Update the BindIP from 127.0.0.1 to 0.0.0.0 in config file /etc/redis.conf & /etc/redis/redis.conf

  systemctl enable redis &>>{LOG_FILE} && systemctl start redis &>>{LOG_FILE}
  stat_check $? "start redis service"

  ##Rabbitmq setup
  echo -e "                -------->>>>>> \e[1;35mRabbitMQ Setup\e[0m  <<<<<<-------------"

  curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash &>>{LOG_FILE}
  stat_check $? "Download RabbitMQ repo"

 yum install https://github.com/rabbitmq/erlang-rpm/releases/download/v23.2.6/erlang-23.2.6-1.el7.x86_64.rpm rabbitmq-server -y &>>{LOG_FILE}
 stat_check $? "Install erlnag and rabbitmq "

systemctl enable rabbitmq-server &>>{LOG_FILE} && systemctl start rabbitmq-server&>>{LOG_FILE}
stat_check $? "Start rabbitmq service"

rabbitmqctl add_user roboshop roboshop123 &>>{LOG_FILE}
stat_check $? "Create Application user in Rabbitmq"



  # rabbitmqctl set_user_tags roboshop administrator
  # rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"

