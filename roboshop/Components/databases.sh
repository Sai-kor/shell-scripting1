#!/bin/bash
source Components/common.sh
###Mongodb setup
echo -e "                -------->>>>>> \e[1;35mMongoDB Setup\e[0m  <<<<<<-------------"

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

  yum install redis -y &>>${LOG_FILE}
  stat_check $? "Install redis"

  sed -i 's/127.0.0.1/0.0.0.0/' /etc/redis.conf /etc/redis/redis.conf &>>${LOG_FILE}
  stat_check $? "update redis config file"
 #Update the BindIP from 127.0.0.1 to 0.0.0.0 in config file /etc/redis.conf & /etc/redis/redis.conf

  systemctl enable redis &>>${LOG_FILE} && systemctl restart redis &>>${LOG_FILE}
  stat_check $? "start redis service"

  ##Rabbitmq setup
  echo -e "                -------->>>>>> \e[1;35mRabbitMQ Setup\e[0m  <<<<<<-------------"

  curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash &>>{LOG_FILE}
  stat_check $? "Download RabbitMQ repo"

 yum install https://github.com/rabbitmq/erlang-rpm/releases/download/v23.2.6/erlang-23.2.6-1.el7.x86_64.rpm rabbitmq-server -y &>>{LOG_FILE}
 stat_check $? "Install erlnag and rabbitmq "

systemctl enable rabbitmq-server &>>{LOG_FILE} && systemctl start rabbitmq-server&>>{LOG_FILE}
stat_check $? "Start rabbitmq service"

rabbitmqctl list_users|grep roboshop &>>{LOG_FILE}
if [ $? -ne 0 ]; then
  rabbitmqctl add_user roboshop roboshop123 &>>{LOG_FILE}
  stat_check $? "Create Application user in Rabbitmq"
fi
rabbitmqctl set_user_tags roboshop administrator &>>{LOG_FILE} && rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>{LOG_FILE}
stat_check $? "Configure App user permissions"

##Mysql setup
echo -e "                -------->>>>>> \e[1;35mMysql Setup\e[0m  <<<<<<-------------"
curl -s -L -o /etc/yum.repos.d/mysql.repo https://raw.githubusercontent.com/roboshop-devops-project/mysql/main/mysql.repo &>>${LOG_FILE}
stat_check $? "Download mysql repo"

yum install mysql-community-server -y &>>${LOG_FILE}
stat_check $? "Install mysql"

systemctl enable mysqld&>>${LOG_FILE} && systemctl start mysqld &>>${LOG_FILE}
stat_check $? "Start mysql service"

DEFAULT_PASSWORD=$(sudo grep 'temporary password' /var/log/mysqld.log |awk '{print $NF}')

echo 'show databases;'|mysql -uroot -pRoboshop@1 &>>{LOG_FILE}
if [ $? -ne 0 ]; then
  echo "ALTER USER 'root'@'localhost' IDENTIFIED BY 'Roboshop@1';" >/tmp/pass.sql
  mysql --connect-expired-password -uroot -p"${DEFAULT_PASSWORD}" < /tmp/pass.sql &>>${LOG_FILE}
  stat_check $? "Setup new root password"
fi

echo 'show plugins;'|mysql -uroot -pRoboshop@1 2>>{LOG_FILE}|grep 'validate_password' &>>{LOG_FILE}
#echo $?
if [ $? -eq 0 ]; then
  echo 'uninstall plugin validate_password;'|mysql -uroot -pRoboshop@1 &>>{LOG_FILE}
  stat_check $? "Uninstall password plugin"
fi

DOWNLOAD mysql
cd /tmp/mysql-main
mysql -u root -pRoboshop@1 <shipping.sql &>>{LOG_FILE}
stat_check $? "Load schema to mysql"