#!/bin/bash
user=$(id -u)
log_folder="/var/log/mysql-logs"
log_file="/var/log/mysql-logs/$0.log"

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

dnf install mysql-server -y
validate $? "install mysql-server..."

systemctl enable mysqld
systemctl start mysqld  

validate $? "enable and start mysql.."
mysql_secure_installation --set-root-pass RoboShop@1
validate $? "set root password..."