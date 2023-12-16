#!/bin/bash
ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
TIMESTAMP=$(date +%F-%H-%M-%s)
LOGFILE="/tmp/$0-$TIMESTAMP.log"
echo "script started executing at timestamp::$TIMESTAMP" &>>$LOGFILE
$MYSQL_HOST=mysql.sowjanyaaws.xyz
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

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>> $LOGFILE
VALIDATE $? "downloading erlang script"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>> $LOGFILE
VALIDATE $? "downloading repos for rabbitmq"

dnf install rabbitmq-server -y &>> $LOGFILE
VALIDATE $? "installing rabbitmq"

systemctl enable rabbitmq-server &>> $LOGFILE
VALIDATE $? "enabling rabbitmq" 

systemctl start rabbitmq-server &>> $LOGFILE
VALIDATE $? "starting rabbitmq" 

rabbitmqctl add_user roboshop roboshop123 &>> $LOGFILE
VALIDATE $? "adding roboshop user & password"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOGFILE
VALIDATE $? "setting permissions"
