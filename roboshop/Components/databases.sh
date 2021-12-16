#!/bin/bash

###Mongodb setup
#echo -e "                -------->>>>>> \e[1;35mMongoDB Setup\e[0m  <<<<<<-------------"
#source Components/common.sh
#curl -s -o /etc/yum.repos.d/mongodb.repo https://raw.githubusercontent.com/roboshop-devops-project/mongodb/main/mongo.repo &>>${LOG_FILE}
#stat_check $? "Download mongodb repo"
#
#yum install -y mongodb-org &>>${LOG_FILE}
#stat_check $? "Install Mongodb"
#
#sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf &>>${LOG_FILE}
#stat_check $? "Update Mongodb service"
#
#systemctl enable mongod &>>${LOG_FILE} && systemctl restart mongod &>>${LOG_FILE}
#stat_check $? "Start MongoDB Service"
#
#DOWNLOAD mongodb
#
# cd /tmp/mongodb-main
# mongo < catalogue.js &>>${LOG_FILE}&& mongo < users.js&>>${LOG_FILE}
# stat_check $? "Load Schema"
#
# ##Redis setup
# echo -e "                -------->>>>>> \e[1;35mRedis Setup\e[0m  <<<<<<-------------"
# curl -L https://raw.githubusercontent.com/roboshop-devops-project/redis/main/redis.repo -o /etc/yum.repos.d/redis.repo &>>{LOG_FILE}
#  stat_check $? "Download Redis Repo"
#
#  yum install redis -y &>>{LOG_FILE}
#  stat_check $? "Install redis"
#
#  sed -i 's/127.0.0.1/0.0.0.0/' /etc/redis.conf &>>{LOG_FILE}
#  stat_check $? "update redis config file"
# #Update the BindIP from 127.0.0.1 to 0.0.0.0 in config file /etc/redis.conf & /etc/redis/redis.conf
#
#  systemctl enable redis &>>{LOG_FILE} && systemctl start redis &>>{LOG_FILE}
#  stat_check $? "start redis service"
#
#  ##Rabbitmq setup
#  echo -e "                -------->>>>>> \e[1;35mRabbitMQ Setup\e[0m  <<<<<<-------------"
#
#  curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash &>>{LOG_FILE}
#  stat_check $? "Download RabbitMQ repo"
#
# yum install https://github.com/rabbitmq/erlang-rpm/releases/download/v23.2.6/erlang-23.2.6-1.el7.x86_64.rpm rabbitmq-server -y &>>{LOG_FILE}
# stat_check $? "Install erlnag and rabbitmq "
#
#systemctl enable rabbitmq-server &>>{LOG_FILE} && systemctl start rabbitmq-server&>>{LOG_FILE}
#stat_check $? "Start rabbitmq service"
#
#rabbitmqctl list_users|grep roboshop &>>{LOG_FILE}
#if [ $? -ne 0 ]; then
#  rabbitmqctl add_user roboshop roboshop123 &>>{LOG_FILE}
#  stat_check $? "Create Application user in Rabbitmq"
#fi
#rabbitmqctl set_user_tags roboshop administrator &>>{LOG_FILE} && rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>{LOG_FILE}
#stat_check $? "Configure App user permissions"

##Mysql setup
echo -e "                -------->>>>>> \e[1;35mMysql Setup\e[0m  <<<<<<-------------"
curl -s -L -o /etc/yum.repos.d/mysql.repo https://raw.githubusercontent.com/roboshop-devops-project/mysql/main/mysql.repo &>>${LOG_FILE}
stat_check $? "Download mysql repo"

yum install mysql-community-server -y &>>${LOG_FILE}
stat_check $? "Install mysql"

systemctl enable mysqld&>>${LOG_FILE} && systemctl start mysqld &>>${LOG_FILE}
stat_check $? "Start mysql service"

DEFAULT_PASSWORD=$(sudo grep 'temporary password' /var/log/mysqld.log |awk '{print $NF}')

echo "ALTER USER 'root'@'localhost' IDENTIFIED BY 'Roboshop@1';" >/tmp/pass.sql
mysql --connect-expired-password -uroot -p"${DEFAULT_PASSWORD}" < /tmp/pass.sql &>>{LOG_FILE}
stat_check $? "Setup new root password"

#Next, We need to change the default root password in order to start using the database service.
# mysql_secure_installation

#You can check the new password working or not using the following command.

# mysql -u root -p

#Run the following SQL commands to remove the password policy.
#> uninstall plugin validate_password;
#Setup Needed for Application.
#As per the architecture diagram, MySQL is needed by

#Shipping Service
#So we need to load that schema into the database, So those applications will detect them and run accordingly.

#To download schema, Use the following command

# curl -s -L -o /tmp/mysql.zip "https://github.com/roboshop-devops-project/mysql/archive/main.zip"
#Load the schema for Services.

# cd /tmp
# unzip mysql.zip
# cd mysql-main
# mysql -u root -pRoboShop@1 <shipping.sql