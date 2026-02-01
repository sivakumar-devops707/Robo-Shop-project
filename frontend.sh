#!/bin/bash

user=$(id -u)
log_folder="/var/log/catalouge-logs"
log_file="/var/log/catalouge-logs/$0.log"
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

dnf module disable nginx -y
validate $? "disable nginx"
dnf module enable nginx:1.24 -y
validate $? "enable nginx"
dnf install nginx -y
validate $? "install nginx"

systemctl enable nginx 
systemctl start nginx 
validate $? "enable and start nginx"

rm -rf /usr/share/nginx/html/* 
validate $? "removing nginx html"
cd /usr/share/nginx/html 
validate $? "changing folder nginx html"

unzip /tmp/frontend.zip
validate $? "unzip nginx html"

cp $SCRIPT_DIR/frontend.conf /etc/nginx/nginx.conf
validate $? "frontend configuration ..."

systemctl restart nginx 
validate $? "nginx restarted......"