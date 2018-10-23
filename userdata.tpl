#!/bin/bash

sudo apt-get update
sudo apt-get install -y openjdk-8-jdk git ruby wget apache2 python-pip
sudo pip install awscli
sudo a2enmod ssl
sudo a2enmod proxy
sudo a2enmod proxy_balancer
sudo a2enmod proxy_http


availability_zone=$(curl http://169.254.169.254/latest/meta-data/placement/availability-zone)
region=$(echo $availability_zone | sed 's/[a-z]$//')
wget https://aws-codedeploy-$region.s3.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto
sudo service codedeploy-agent start


'[Unit]
Description = Java Service
After network.target = MyService.service

[Service]
Type = forking
ExecStart = /usr/local/bin/MyService.sh start
ExecStop = /usr/local/bin/MyService.sh stop
ExecReload = /usr/local/bin/MyService.sh reload

[Install]
WantedBy=multi-user.target
' >> /etc/systemd/system/MyService.service

'#!/bin/sh
SERVICE_NAME=MyService
PATH_TO_JAR=/app/ops_test/target/suchapp-0.0.1-SNAPSHOT.jar
PROP_FILE==/tmp/application.properties
PID_PATH_NAME=/tmp/MyService-pid
case $1 in
    start)
        echo "Starting $SERVICE_NAME ..."
        if [ ! -f $PID_PATH_NAME ]; then
            nohup java -jar $PATH_TO_JAR -Dspring.config.location=$PROP_FILE /tmp 2>> /dev/null >> /dev/null &
                        echo $! > $PID_PATH_NAME
            echo "$SERVICE_NAME started ..."
        else
            echo "$SERVICE_NAME is already running ..."
        fi
    ;;
    stop)
        if [ -f $PID_PATH_NAME ]; then
            PID=$(cat $PID_PATH_NAME);
            echo "$SERVICE_NAME stoping ..."
            kill $PID;
            echo "$SERVICE_NAME stopped ..."
            rm $PID_PATH_NAME
        else
            echo "$SERVICE_NAME is not running ..."
        fi
    ;;
    restart)
        if [ -f $PID_PATH_NAME ]; then
            PID=$(cat $PID_PATH_NAME);
            echo "$SERVICE_NAME stopping ...";
            kill $PID;
            echo "$SERVICE_NAME stopped ...";
            rm $PID_PATH_NAME
            echo "$SERVICE_NAME starting ..."
            nohup java -jar $PATH_TO_JAR -Dspring.config.location=$PROP_FILE /tmp 2>> /dev/null >> /dev/null &
                        echo $! > $PID_PATH_NAME
            echo "$SERVICE_NAME started ..."
        else
            echo "$SERVICE_NAME is not running ..."
        fi
    ;;
esac' >> /usr/local/bin/MyService.sh

sudo chmod +x /usr/local/bin/MyService.sh
sudo systemctl enable MyService