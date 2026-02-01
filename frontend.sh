#!/bin/bash

user=$(id -u)
log_folder="/var/log/fend-logs"
log_file="/var/log/fend-logs/$0.log"
SCRIPT_DIR=$PWD
MONGODB_HOST="mongodb.sivadevops707.online"
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

dnf module disable nginx -y &>>$log_file
validate $? "disable nginx"
dnf module enable nginx:1.24 -y &>>$log_file
validate $? "enable nginx"
dnf install nginx -y &>>$log_file
validate $? "install nginx"

systemctl enable nginx &>>$log_file 
systemctl start nginx &>>$log_file
validate $? "enable and start nginx"

rm -rf /usr/share/nginx/html/*  &>>$log_file
validate $? "removing nginx html"
cd /usr/share/nginx/html &>>$log_file
validate $? "changing folder nginx html"
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$log_file
validate $? "downloaded zip file..."
unzip /tmp/frontend.zip &>>$log_file
validate $? "unzip nginx html"

cp $SCRIPT_DIR/frontend.conf /etc/nginx/nginx.conf &>>$log_file
validate $? "frontend configuration ..."

systemctl restart nginx  &>>$log_file
validate $? "nginx restarted......"