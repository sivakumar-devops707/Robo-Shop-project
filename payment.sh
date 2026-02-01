#!/bin/bash

user=$(id -u)
log_folder="/var/log/cart-logs"
log_file="/var/log/cart-logs/$0.log"
SCRIPT_DIR=$PWD
catalouge_HOST="catalouge.sivadevops707.online"
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

dnf install python3 gcc python3-devel -y &>>$log_file
validate $? "install python3 gcc python3-devel"

id roboshop &>>$log_file

if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$log_file
    validate $? "Creating system user"
else
    echo "Roboshop user already exist ...  SKIPPING"
fi
mkdir -p /app &>>$log_file
validate $? "creating app directory"
rm -rf /app/* &>>$log_file

validate $? "Removing existing code"

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$log_file
validate $? "downloading code from git"
cd /app 
validate $? "change directory"
unzip /tmp/payment.zip &>>$log_file
validate $? "unzip code.."
cd /app 
pip3 install -r requirements.txt &>>$log_file
validate $? "requirements.txt install.."

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service &>>$log_file
validate $? "copying user service..."

systemctl daemon-reload &>>$log_file
validate $? "daemon reload ..."

systemctl enable payment &>>$log_file
systemctl start payment &>>$log_file
validate $? "start payment..."