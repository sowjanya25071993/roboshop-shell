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

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "copied repo file ....."
dnf install mongodb-org -y  &>> $LOGFILE
VALIDATE $? "installing mongodb......"
systemctl enable mongod &>> $LOGFILE
VALIDATE $? "enabling mongodb....."

systemctl start mongod &>> $LOGFILE
VALIDATE $? "starting mongodb....."
sed -i "s/127.0.0.1/0.0.0.0/g"  /etc/mongod.conf &>> $LOGFILE
VALIDATE $? "updating mongodb config file....."
systemctl restart mongod &>> $LOGFILE
VALIDATE $? "restarting mongodb....."