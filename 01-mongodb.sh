#!/bin/bash
#to set logs = sudo mkdir /var/log/roboshop
LOGS_FOLDER="/var/log/roboshop" #creates a folder inside var log.
sudo mkdir -p $LOGS_FOLDER #-p it will be silent when then file(name) is present or create.
sudo chown -R ec2-user:ec2-user $LOGS_FOLDER #ec2-user permissons .
sudo chmod -R 755 $LOGS_FOLDER
LOGS_FILE="$LOGS_FOLDER/$0.log"

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

if [ $USERID -ne 0 ]; then
    echo -e "$TIMESTAMP [ERROR] $R Please run the script with root access. $N" | tee -a $LOGS_FILE
    exit 1
fi 

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$TIMESTAMP [ERROR] $2 ... $R FAILURE $N" | tee -a $LOGS_FILE
        exit 1
    else 
        echo -e "$TIMESTAMP [INFO] $2 ... $G SUCCESS $N" | tee -a $LOGS_FILE 
    fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Adding Mongo repo" #if the copying is been failed then $? will be non zero whereas adding mongo failure.

dnf install mongodb-org -y &>> &LOGS_FILE 
VALIDATE $? "Installing MongoDB"