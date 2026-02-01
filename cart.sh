#!/bin/bash

user=$(id -u)
log_folder="/var/log/cart-logs"
log_file="/var/log/cart-logs/$0.log"
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

dnf module disable nodejs -y &>>$log_file
dnf module enable nodejs:20 -y &>>$log_file
validate $? "enable nodejs"

dnf install nodejs -y &>>$log_file
validate $? "install nodejs"

id roboshop &>>$log_file
echo $?
if [ $? -ne 0 ]; then
      useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$log_file
    validate $? "Creating system user"
else
    echo "Roboshop user already exist ...  SKIPPING"
fi
mkdir -p /app 
validate $? "creating app directory"
rm -rf /app/*

validate $? "Removing existing code"

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>>$log_file
validate $? "downloading code from git"
cd /app 
validate $? "change directory"
unzip /tmp/cart.zip &>>$log_file
validate $? "unzip code.."
cd /app 
npm install &>>$log_file
validate $? "npm install.."

cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service &>>$log_file
validate $? "copying user service..."

systemctl daemon-reload &>>$log_file
validate $? "daemon reload ..."

systemctl enable cart &>>$log_file
systemctl start cart &>>$log_file
validate $? "start cart..."