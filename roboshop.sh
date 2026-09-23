#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
ZONE_ID="Z076627518YDYQ0034ZJQ"   # replace with zone id
DOMAIN_NAME="raj03.sbs"   # replace with your domain name

for instance in $@
do
    echo "Launching instance: $instance"
    INSTANCE_ID=$(aws ec2 run-instances \
    --image-id ami-0220d79f3f480ecf5 \
    --instance-type t3.micro \
    --security-groups "roboshop-common" "roboshop-$instance" \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=roboshop-$instance}]" \
    --query 'Instances[0].InstanceId' \
    --output text\
    )
done 