#!/bin/bash
availability_zone=$(curl http://169.254.169.254/latest/meta-data/placement/availability-zone)
prop_file="/tmp/application.properties"

sudo apt-get update
sudo apt-get install -y openjdk-8-jdk
sudo apt-get install git


sudo mkdir /app
cd /app && sudo git clone https://github.com/lc-nyovchev/opstest.git
echo "suchname=$availability_zone" > $prop_file
cd opstest && sudo ./mvnw spring-boot:run -Dspring.config.location=$prop_file