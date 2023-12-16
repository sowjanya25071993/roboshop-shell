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
VALIDATE $? "disabling current nodejs"


dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? "enabling nodejs 18"

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "installing nodejs"

useradd roboshop &>> $LOGFILE
VALIDATE $? "adding user roboshop"

mkdir /app &>> $LOGFILE
VALIDATE $? "creating directory app"

curl  -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE
VALIDATE $? "unzipping the code"

cd /app &>> $LOGFILE
VALIDATE $? "moving to app directory" 

unzip /tmp/user.zip &>> $LOGFILE
VALIDATE $? "unzipping user"

npm install  &>> $LOGFILE
VALIDATE $? "installing dependancies"

cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service &>> $LOGFILE
VALIDATE $? "copying the user code"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "reloading daemon"

systemctl enable user  &>> $LOGFILE
VALIDATE $? "enabling user"

systemctl start user &>> $LOGFILE
VALIDATE $? "starting user"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "copying mongo repo"

dnf install mongodb-org-shell -y &>> $LOGFILE
VALIDATE $? "installing mongo client "

mongo --host $MONGODB_HOST </app/schema/user.js &>> $LOGFILE
VALIDATE $? "loading user schema"
