#! /bin/bash
dnf update -y
dnf install java-17-amazon-corretto-devel -y
cd /tmp && wget https://dlcdn.apache.org/tomcat/tomcat-11/v11.0.6/bin/apache-tomcat-11.0.6.zip
unzip apache-tomcat-*.zip
mv apache-tomcat-11.0.6 /opt/tomcat
chmod +x /opt/tomcat/bin/*
