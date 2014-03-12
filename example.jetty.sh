#!/bin/bash

AUTO_UPDATE_ENABLED="1"

APPLICATION_SERVER_START="service jetty8 start"
APPLICATION_SERVER_STOP="service jetty8 stop"
APPLICATION_SERVER_STATUS="service jetty8 status"

WAR_BACKUP_FOLDER="/root/backups/wars/"
WEBAPPS_FOLDER="/var/lib/jetty8/webapps/"
FINAL_WAR_NAME="ROOT.war"

WAR_FOLDER="/root/"
NEW_WAR_NAME="deployable.war"

source $(dirname $(readlink -f $0))/management.sh
