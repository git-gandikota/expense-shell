#!/bin/bash

TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

USERID=$(id -u)

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2....$R Failed $N"
        exit 1
    else
        echo -e "$2....$G suceess $N"
    fi
}

if [ $USERID -ne 0 ]
then
    echo "Please run this script with root access."
    exit 1 #manually exit if error comes.
else
    echo "You are Super user"
fi

dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "Installing mysql server"

systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "Enabling mysql server"

systemctl start mysqld &>>$LOGFILE
VALIDATE $? "Starting mysql server"

#mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
#VALIDATE $? "Setting up root password"

#Below code will be useful for idempotent nature
mysql -h db.ramdaws.cloud -uroot -pExpenseApp@1 -e 'show databases;' &>>$LOGFILE
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ExpenseApp@1
    VALIDATE $?"MySQL Root password Setup"
else
    echo -e "MySQL Root password is already setup...$Y SKIPPING $N"
fi