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
   thisDist="$(grep "^NAME=" $ETC/os-release | cut -d "=" -f2 | tr -d "\"" | awk '{ print $1 }')"
   thisRel="$(grep "^VERSION=" $ETC/os-release | cut -d "=" -f2 | tr -d "\"" | cut -d " " -f1 | cut -d "." -f1)"
fi


case "$thisDist" in
   "Debian"|"Ubuntu")
      # Get and install the Jenkins signing key
      wget -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add -

      # Check for Java and if exist, remove and install OpenJDK
      JAVAINST="$(java -version)"

      if [ "$JAVAINST" = "" ]; then
         apt-get install openjdk-7-jre -y
      fi

      # Setup Jenkins repo and install
      if [ ! -e /etc/apt/sources.list.d/jenkins.list ]; then
         echo "deb http://pkg.jenkins-ci.org/debian-stable binary/" > /etc/apt/sources.list.d/jenkins.list
         apt-get update && apt-get install jenkins -y
      fi
   ;;

   *)
      echo "$thisDist is currently not supported"
   ;;

esac

echo "...Complete..."
