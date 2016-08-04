#!/usr/bin/env bash

# This script will install Jenkins on this computer

# Get and install the Jenkins signing key
wget -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add -

# Check for Java and if exist, remove and install OpenJDK
JAVAINST="$(java -version)"

if [ "$JAVAINST" = "" ]; then
   apt-get install openjdk-7-jre -y
fi

if [ ! -e /etc/apt/sources.list.d/jenkins.list ]; then
   echo "deb http://pkg.jenkins-ci.org/debian-stable binary/" > /etc/apt/sources.list.d/jenkins.list
   apt-get update && apt-get install jenkins -y
fi

echo "...Complete..."
