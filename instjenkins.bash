#!/usr/bin/env bash

# This script will install Jenkins on this computer
# This file can be run on CentOS, Debian or Ubuntu machines without issues
# If issues are found, please submit update and push changes if you
#   are comfortable with using Git and BASH scripting

# Constant variables
CURDIR="$(pwd)"
LOGFILE="/var/log/log_Jenkins_`date '+%F_%H-%M-%S'`.log"
ETC="/etc"
thisArch="$(uname -m)"
myRunLVL=$(runlevel | awk '{ print $2 }')

if [ -e /usr/bin/lsb_release ]; then
   thisDist="$(lsb_release -i | awk '{ print $3 }')"
   thisRel="$(lsb_release -r | awk '{ print $2 }' | cut -d '.' -f1)"
else
   thisDist="$(grep "^NAME=" /etc/os-release | cut -d "=" -f2 | tr -d "\"" | awk '{ print $1 }')"
   thisRel="$(grep "^VERSION=" /etc/os-release | cut -d "=" -f2 | tr -d "\"" | cut -d " " -f1 | cut -d "." -f1)"
fi

# Check for Java
JAVAINST="$(java -version)"

case "$thisDist" in
   Debian|Ubuntu)
      # Get and install the Jenkins signing key
      wget -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add -

      if [ "$JAVAINST" = "" ]; then
         apt-get install openjdk-7-jre -y
      fi

      # Setup Jenkins repo and install
      if [ ! -e /etc/apt/sources.list.d/jenkins.list ]; then
         echo "deb http://pkg.jenkins-ci.org/debian-stable binary/" > /etc/apt/sources.list.d/jenkins.list
         apt-get update && apt-get install jenkins -y
      fi
   ;;

   CentOS*|RedHat*)
      if [ $(id -u) = 0 ]; then
         if [ "$JAVAINST" = "" ]; then
            yum install java -y
         fi

         if [ ! -e /etc/yum.repos.d/jenkins.repo ]; then
            wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
            rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key
            yum update -y && yum install jenkins -y

            # Allow public access to Jenkins if the firewall is enabled
            if [ "$(firewall-cmd --state)" = "running" ]; then
               firewall-cmd --zone=public --add-port=8080/tcp --permanent
               firewall-cmd --zone=public --add-port=http --permanent
               firewall-cmd --reload
            fi
         fi
      fi
   ;;

   *)
      echo "$thisDist is currently not supported"
   ;;

esac

echo "...Complete..."
