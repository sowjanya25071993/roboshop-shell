#!/bin/bash
ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGODB_HOST=mongodb.sowjanyaaws.xyz
TIMESTAMP=$(date +%F-%H-%M-%s)

LOGFILE="/tmp/$0-$TIMESTAMP.log"
echo "script started executing at timestamp::$TIMESTAMP" &>>$LOGFILE
VALIDATE(){
    if [ $1 -ne 0 ]
    then 
    echo -e "$2.....$R......failed.....$N"
    exit 1
    else
    echo -e "$2......$G......success.....$N"
    fi
}
if [ $ID -ne 0 ]
then 
echo -e " $R pls run this script with root access..."
exit 1
else
echo "u r root user"
fi

dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "disabling  current nodejs"

dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? "enabling nodejs 18"

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "installing nodejs 18"

useradd roboshop &>> $LOGFILE
VALIDATE $? "creating user roboshop"

mkdir /app &>> $LOGFILE
VALIDATE $? "making app directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE
VALIDATE $? "downloading catalogue"

cd /app  &>> $LOGFILE
VALIDATE $? "moving to app directory"

unzip /tmp/catalogue.zip &>> $LOGFILE
VALIDATE $? "unzipping catalogue"

npm install &>> $LOGFILE
VALIDATE $? "installing ndependancies" 

cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE
VALIDATE $? "copying catalogue service file"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "reloading daemon"

systemctl enable catalogue &>> $LOGFILE
VALIDATE $? "enabling catalogue"

systemctl start catalogue &>> $LOGFILE
VALIDATE $? "starting catalogue"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "copying mongo repo"

dnf install mongodb-org-shell -y
VALIDATE $? "installing mongodb client"

mongo --host $MONGODB_HOST </app/schema/catalogue.js
VALIDATE $? "loading schema"