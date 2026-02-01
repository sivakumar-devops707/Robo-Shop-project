#!/bin/bash

user=$(id -u)
log_folder="/var/log/redis-logs"
log_file="/var/log/redis-logs/$0.log"

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

dnf module disable redis -y &>>$log_file
validate $? "module disable redis...."
dnf module enable redis:7 -y &>>$log_file
validate $? "module enable redis:7...."

dnf install redis -y &>>$log_file
validate $? "install redis..."

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf &>>$log_file
validate $? "accessing remotenetworking....."
sed -i 's/yes/no/g' /etc/redis/redis.conf &>>$log_file
validate $? "changing redis conf yes to no..."
systemctl enable redis &>>$log_file
systemctl start redis &>>$log_file
validate $? "start redis..."
