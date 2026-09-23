#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
ZONE_ID="Z076627518YDYQ0034ZJQ"   #repalce with zone id
DOMAIN_NAME="raj03.sbs"   #repalce with your domain name



for instance in $@
do
    echo "Launching instance: $instance"
    INSTANCE_ID=$(aws ec2 run-instances \
     
        --image-id ami-0220d79f3f480ecf5 \
        --instance-type t3.micro \
        --security-groups "roboshop-common" "roboshop-$instance" \ 
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=roboshop-$instance}]" \
        --query 'Instances[0].InstanceId' \
        --output text
    )
    echo "Instance ID: $INSTANCE_ID"

    if [ $instance == "frontend" ]; then
    IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID \
        --query 'Reservations[*].Instances[*].PublicIpAddress' \
        --output text
        R53_RECORD="$DOMAIN_NAME"
        
        
        )
    else
    IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID \
        --query 'Reservations[*].Instances[*].PrivateIpAddress' \
        --output text 
        R53_RECORD="$instance.$DOMAIN_NAME"     #EX: if mongodb then mongodb.raj03.sbs
        )
    fi

    #### UPDATING ROUTE53 RECORDS #####
    #search: aws cli to update route 53 record.
    aws route53 change-resource-record-sets \
    --hosted-zone-id "$ZONE_ID" \
    --change-batch '
        {
            "Comment": "Updating A record to a new IP",
            "Changes": [
                {
                    "Action": "UPSERT",
                    "ResourceRecordSet": {
                        "Name": "'$R53_RECORD'",
                        "Type": "A",
                        "TTL": 1,
                        "ResourceRecords": [
                            {
                                "Value": "'$IP'"
                            }
                        ]
                    }
                }
            ]
        }
    '


done
