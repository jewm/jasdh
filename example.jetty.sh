#!/bin/bash

AUTO_UPDATE_ENABLED="1"

APPLICATION_SERVER_START="service jetty8 start"
APPLICATION_SERVER_STOP="service jetty8 stop"
APPLICATION_SERVER_STATUS="service jetty8 status"

WAR_BACKUP_FOLDER="/root/backups/wars/"
CURRENT_WAR="/var/lib/jetty8/webapps/ROOT.war"
NEW_WAR="/root/deployable.war"


source $(dirname $(readlink -f $0))/management.sh
