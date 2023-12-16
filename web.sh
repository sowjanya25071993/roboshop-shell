#!/bin/bash
ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
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

dnf install nginx -y &>> $LOGFILE
VALIDATE $? "installing nginx"

systemctl enable nginx &>> $LOGFILE
VALIDATE $? "enabling nginx"

systemctl start nginx &>> $LOGFILE
VALIDATE $? "starting nginx"

rm -rf /usr/share/nginx/html/* &>> $LOGFILE
VALIDATE $? "removing default nginx"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE
VALIDATE $? "downloading devloped nginx page"

cd /usr/share/nginx/html &>> $LOGFILE
VALIDATE $? "changing to directory of nginx"

unzip /tmp/web.zip &>> $LOGFILE
VALIDATE $? "unzipping nginx code"

cp /home/centos/roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf &>> $LOGFILE
VALIDATE $? "copying roboshop cong file"

systemctl restart nginx &>> $LOGFILE
VALIDATE $? "restarting nginx"


