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
fi

dnf install python36 gcc python3-devel -y &>> $LOGFILE
VALIDATE $? "installing python36"
id roboshop
if [ $? -ne 0 ]
then 
useradd roboshop &>> $LOGFILE
VALIDATE $? "adding roboshop user"
else
echo -e " user roboshop already exists...$Y...skipping...$N"
fi

mkdir -p /app &>> $LOGFILE
VALIDATE $? "creating app directory"

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE
VALIDATE $? "downloading payment code"

cd /app  &>> $LOGFILE
VALIDATE $? "changing to app directory"

unzip -o /tmp/payment.zip &>> $LOGFILE
VALIDATE $? "unzippping the code"

pip3.6 install -r requirements.txt &>> $LOGFILE
VALIDATE $? "installing dependancies"

cp /home/centos/roboshop-shell/payments.service /etc/systemd/system/payment.service &>> $LOGFILE
VALIDATE $? "copying payment service file"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "reloading daemon"

systemctl enable payment &>> $LOGFILE
VALIDATE $? "enabling payment"

systemctl start payment &>> $LOGFILE
VALIDATE $? "starting payment"