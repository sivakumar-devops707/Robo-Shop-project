#!/bin/bash

user=$(id -u)
log_folder="/var/log/catalouge-logs"
log_file="/var/log/catalouge-logs/$0.log"

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

dnf module disable nodejs -y &>>$log_file
validate $? "disable nodejs"
dnf module enable nodejs:20 -y &>>$log_file
validate $? "enable nodejs"
dnf install nodejs -y &>>$log_file
validate $? "install nodejs"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$log_file
validate $? "useradded...."

mkdir /app 
validate $? "creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$log_file
validate $? "downloading code from git"
cd /app 
validate $? "change directory"
unzip /tmp/catalogue.zip &>>$log_file
validate $? "unzip code.."
cd /app 
npm install &>>$log_file
validate $? "npm install.."

cp catalogue.service /etc/systemd/system/catalogue.service &>>$log_file
validate $? "copying catalogue service..."

systemctl daemon-reload &>>$log_file
validate $? "daemon reload ..."

systemctl enable catalogue &>>$log_file
systemctl start catalogue &>>$log_file
validate $? "start catalogue..."