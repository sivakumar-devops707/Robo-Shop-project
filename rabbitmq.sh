#!/bin/bash

user=$(id -u)
log_folder="/var/log/rabbitmq-logs"
log_file="/var/log/rabbitmq-logs/$0.log"
SCRIPT_DIR=$PWD
REDIS_HOST="redis.sivadevops707.online"
if [ $user -ne 0 ]; then
    echo "please run as sudo user / root user" | tee -a $log_file
   exit 1

fi
mkdir -p $log_folder
validate(){
    if [ $1 -ne 0 ]; then
      echo "installing $2 failure...." | tee -a $log_file
      exit 1
    else

      echo "installing  $2  success" | tee -a $log_file
    fi
}

cp $SCRIPT_DIR/rabbitmq /etc/yum.repos.d/rabbitmq.repo &>>$log_file
validate $? "Setup the RabbitMQ repo file...."

dnf install rabbitmq-server -y &>>$log_file
validate $? "install rabbitmq-server..."

systemctl enable rabbitmq-server &>>$log_file
systemctl start rabbitmq-server &>>$log_file
validate $? "enable and start rabbitmq-server..."

rabbitmqctl add_user roboshop roboshop123 &>>$log_file
validate $? "add user roboshop..."
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$log_file
validate $? "set permissions..."




