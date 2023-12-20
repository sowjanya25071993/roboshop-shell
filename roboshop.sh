#!/bin/bash
AMI=ami-03265a0778a880afb
SG_ID=sg-041ad45b2bacfa73b
INSTANCES=("user" "mongodb" "cart" "mysql" "redis" "rabbitmq" "cart" "dispatch" "web" "catalogue" "payment")
ZONE_ID=Z0380517BLU5489E8PQ
DOMAIN_NAME="sowjanyaaws.xyz"
for i in "${INSTANCES[@]}"
do
if [ $i=="mongodb" ] || [ $i=="mysql" ] || [ $i=="shipping" ]
then
INSTANCE_TYPE="t3.small"
else
INSTANCE_TYPE="t2.micro"
fi
IP_ADDRESS=$(aws ec2 run-instances --image-id $AMI --count 1 --instance-type $INSTANCE_TYPE  --security-group-ids $SG_ID --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=$i}]'  --query 'Instances[0].PrivateIpAddress' --output text)
echo "$i:$IP_ADDRESS"
aws route53 change-resource-record-sets \  --hosted-zone-id $ZONE_ID  \  --change-batch '
{ 
    "Comment": "Testing creating a record set", 
      "Changes": [ { 
    "Action": "CREATE", 
    "ResourceRecordSet": 
    { 
        "Name": " '$i'.'$DOMAIN_NAME'",
         "Type": "A", 
         "TTL": 1,
          "ResourceRecords": [ { 
            "Value": "'$IP_ADDRESS'"
             } ]
              }
               } ]
                }
                '
                done