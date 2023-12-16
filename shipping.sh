#!/bin/bash
ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
TIMESTAMP=$(date +%F-%H-%M-%s)
LOGFILE="/tmp/$0-$TIMESTAMP.log"
echo "script started executing at timestamp::$TIMESTAMP" &>>$LOGFILE
MYSQL_HOST=mysql.sowjanyaaws.xyz
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

dnf install maven -y &>> $LOGFILE
VALIDATE $? "installing maven"
id roboshop
if [ $? -ne 0 ]
then
useradd roboshop &>> $LOGFILE
VALIDATE $? "adding user roboshop"
else
echo -e "user roboshop already exists.....$Y....skipping$N"
fi

mkdir -p /app &>> $LOGFILE
VALIDATE $? "creating app directory"

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE
VALIDATE $? "downloading shippping code"

cd /app &>> $LOGFILE
VALIDATE $? "changing to app directory"

unzip -o /tmp/shipping.zip &>> $LOGFILE
VALIDATE $? "unzipping shipping code"

mvn clean package &>> $LOGFILE
VALIDATE $? "installing dependancies"

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE
VALIDATE $? "renaming jarfiles"

cp /home/centos/roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE
VALIDATE $? "copying shipping service file"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "reloading daemon"

systemctl enable shipping  &>> $LOGFILE
VALIDATE $? "enabling shipping"

systemctl start shipping &>> $LOGFILE
VALIDATE $? "starting shipping"

dnf install mysql -y &>> $LOGFILE
VALIDATE $? "installing mysql client"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/schema/shipping.sql  &>> $LOGFILE
VALIDATE $? "loading schema"

systemctl restart shipping &>> $LOGFILE
VALIDATE $? "restarting shipping"