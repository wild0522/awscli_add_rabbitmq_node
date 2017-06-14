#!/bin/bash

#AWS EC2 DEFAULT=============

name="rabbit-node"
ami="ami-726faa10"
keypairs="rabbitmq_test"
instancetype="t2.micro"
subnetid="subnet-95e3eee0"
securitygid="sg-769e4b11"

#============================

echo "name:($name)"
read _name
if [ ! -z "$_name" -a "$_name" != " " ]; then
name=$_name
fi;

echo "ami:($ami)"
read _ami
if [ ! -z "$_ami" -a "$_ami" != " " ]; then
ami=$_ami
fi;

echo "keypairs:($keypairs)"
read _keypairs
if [ ! -z "$_keypairs" -a "$_keypairs" != " " ]; then
keypairs=$_keypairs
fi;

echo "instance-type:($instancetype)"
read _instancetype
if [ ! -z "$_instancetype" -a "$_instancetype" != " " ]; then
instancetype=$_instancetype
fi;
echo "subnet-id:($subnetid)"
read _subnetid
if [ ! -z "$_subnetid" -a "$_subnetid" != " " ]; then
subnetid=$_subnetid
fi;
echo "security-group-id:($securitygid)"
read _securitygid
if [ ! -z "$_securitygid" -a "$_securitygid" != " " ]; then
securitygid=$_securitygid
fi;


echo "name=$name"
echo "ami=$ami"
echo "keypairs=$keypairs"
echo "instance-type=$instancetype"
echo "subnet-id=$subnetid"
echo "security-group-id=$securitygid"

echo "\nReady to add node? (y/n)"
read y

if [ "$y" = "y" ]; then
  echo ""
else
  echo "bye"
  exit 0
fi;

str=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$name*" --query "Reservations[*].Instances[*].PrivateDnsName" --output=text)
hostname=$(echo $str | cut -d. -f1)
echo "hostname = $hostname"

fname=rabbitmq-node-$hostname.sh
echo "#!/bin/bash" > $fname
echo "hostname=$hostname" >> $fname

f=$(cat rabbitmq-node.sh)
echo "$f" >> $fname

echo "shell_script = $fname"

echo "start run-instances"
aws ec2 run-instances --image-id $ami \
--tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$name}]" \
--key-name $keypairs \
--instance-type $instancetype \
--subnet-id $subnetid \
--security-group-ids $securitygid \
--count 1 \
--user-data file://$fname
