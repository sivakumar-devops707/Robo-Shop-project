#!/bin/bash

user=$(id -u)
log_folder="/var/log/cart-logs"
log_file="/var/log/cart-logs/$0.log"
SCRIPT_DIR=$PWD
mysql_HOST="mysql.sivadevops707.online"
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



curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip 
 &>>$log_file
validate $? "downloading code from git"
cd /app 
validate $? "change directory"
unzip /tmp/shipping.zip &>>$log_file
validate $? "unzip code.."

cd /app 
mvn clean package 
validate $? "clean package.."
mv target/shipping-1.0.jar shipping.jar 
validate $? "shipping jar file..."

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service &>>$log_file
validate $? "copying user service..."

systemctl daemon-reload &>>$log_file
validate $? "daemon reload ..."

systemctl enable shipping &>>$log_file
systemctl start shipping &>>$log_file
validate $? "start cart..."

dnf install mysql -y &>>$log_file
validate $? "install mysql..."

mysql -h $mysql_HOST -uroot -pRoboShop@1 < /app/db/schema.sql &>>$log_file
validate $? "Load Schema, Schema in database ..."

mysql -h $mysql_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql &>>$log_file
validate $? "Create app user, MySQL expects a password authentication ..."

mysql -h $mysql_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$log_file
validate $? "Load Master Data..."

systemctl restart shipping &>>$log_file
validate $? "restart shipping...."