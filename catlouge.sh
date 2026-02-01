#!/bin/bash

user=$(id -u)
log_folder="/var/log/catalouge-logs"
log_file="/var/log/catalouge-logs/$0.log"
SCRIPT_DIR=$PWD
$MONGODB_HOST="mongodb.sivadevops707.online"
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

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "Creating system user"
else
    echo -"Roboshop user already exist ...  SKIPPING"
fi
mkdir -p /app 
validate $? "creating app directory"
rm -rf /app/*
VALIDATE $? "Removing existing code"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$log_file
validate $? "downloading code from git"
cd /app 
validate $? "change directory"
unzip /tmp/catalogue.zip &>>$log_file
validate $? "unzip code.."
cd /app 
npm install &>>$log_file
validate $? "npm install.."

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service &>>$log_file
validate $? "copying catalogue service..."

systemctl daemon-reload &>>$log_file
validate $? "daemon reload ..."

systemctl enable catalogue &>>$log_file
systemctl start catalogue &>>$log_file
validate $? "start catalogue..."

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
dnf install mongodb-mongosh -y &>>$LOGS_FILE

INDEX=$(mongosh --host $MONGODB_HOST --quiet  --eval 'db.getMongo().getDBNames().indexOf("catalogue")')

if [ $INDEX -le 0 ]; then
    mongosh --host $MONGODB_HOST </app/db/master-data.js
    VALIDATE $? "Loading products"
else
    echo -e "Products already loaded ... $Y SKIPPING $N"
fi

systemctl restart catalogue
VALIDATE $? "Restarting catalogue"