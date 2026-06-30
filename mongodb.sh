#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"

if [ $USERID -ne 0 ]; then
    echo -e "$R Please run the script with root user access $N" | tee -a $LOGS_FILE
    exit 1
fi

mkdir -p $LOGS_FOLDER


#$1, $2 argumnets
VALIDATE(){
if [ $1 -ne 0 ]; then
    echo -e "$2 ... $R FAILURE $N " | tee -a $LOGS_FILE
    exit 1
else
    echo -e "$2 ... $G SUCCESS $Y" | tee -a $LOGS_FILE
fi
}


cp mongo.repo /etc/yum.repo.d/mongo.repo
VALIDATE $? "Copying Mongo repo"

dnf install mongodb-org -y &>>$LOGS_FILE
VALIDATE $? "Insatalling Mongodb server"

systemctl enable mongod &>>$LOGS_FILE
VALIDATE $? "Enable Mongodb"

systemctl start mongod 
VALIDATE $? "Start Mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Allowing remote connections"

systemctl restart mongod
VALIDATE $? "Restarted MongoDB"
