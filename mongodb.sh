#!/bin/bash

user=$(id -u)
log_folder="/var/log/mongod-logs"
log_file="/var/log/mongod-logs/$0.log"

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

cd mongod.repo /etc/yum.repos.d/mongo.repo
validate $? "coping the monogod.repo file"

dnf install mongodb-org -y &>>$log_file
validate $? "installing mongodb..."

systemctl enable mongod &>>$log_file
validate $? "enable mongodb..."
systemctl start mongod &>>$log_file
validate $? "start mongodb..."

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>>$log_file
validate $? "accessing remotenetworking....."

systemctl restart mongod &>>$log_file
validate $? "restart mongodb..."
