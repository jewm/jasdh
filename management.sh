#!/bin/bash

## management.sh
# Version: 0.1.1-SNAPSHOT
##

function scriptUpdate {
        wget "https://raw.github.com/jewm/jasdh/master/management.sh" -O "management_new_version.sh" -nv

	if grep -q "Version" "management_new_version.sh";
	then
	        diff -q "management.sh" "management_new_version.sh" 1>/dev/null
	        if [ $? == "0" ]; then
	                echo "No update required"
	                rm "management_new_version.sh"
	        else
	                echo "Update required"
	                rm "management.sh"
	                mv "management_new_version.sh" "management.sh"
	                chmod +x "management.sh"
	                echo "Upload succesful > restart script"
	                ./management.sh
	        fi
	else
		echo "File-content not verified > update aborted"
		rm "management_new_version.sh"
	fi
}

function startServer {
	echo "Starting server..."
	$APPLICATION_SERVER_START
	echo "Server started"
}

function stopServer {
	echo "Stopping server..."
	$APPLICATION_SERVER_STOP
	echo "Server stopped"
}

function serverStatus {
	$APPLICATION_SERVER_STATUS
}

function clearBackupFolder {
	find $WAR_BACKUP_FOLDER -type f -ctime +10 | xargs rm -rf
	echo "Backup-Folder cleared"
}

function deploy {
	echo "Start deployment"

        if [ ! -f "$WAR_FOLDER$CURRENT_WAR_NAME" ]; then
        	echo "$CURRENT_WAR_NAME not found"
        	echo "Deployment aborted"
        	exit 1;
        fi

	if [ ! -d $WEBAPPS_FOLDER ]; then
		echo "$WEBAPPS_FOLDER not found"
		echo "Deployment aborted"
		exit 1;
	fi

	stopServer

	if [ ! -d $WAR_BACKUP_FOLDER ]; then
		mkdir -p $WAR_BACKUP_FOLDER
		echo "Backup-folder created"
	fi

	if [ -f "$WEBAPPS_FOLDER$FINAL_WAR_NAME" ]; then
		mv "$WEBAPPS_FOLDER$FINAL_WAR_NAME" "$WAR_BACKUP_FOLDER$(date +"%Y-%m-%d-%H:%M").war"
		echo "Old war saved"
	fi

	rm -rf "$WEBAPPS_FOLDER*"
	echo "Webapps-folder cleared"

	mv "$WAR_FOLDER$CURRENT_WAR_NAME" "$WEBAPPS_FOLDER$FINAL_WAR_NAME"
	echo "New war moved"

#	if [ "$2" = "--auto-rollback" ]; then
#		echo "Rollback on failure"
#	fi

	startServer

#	if [ ! $APPLICATION_RUNNING ]; then
#		if [ "$2" = "--auto-rollback" ]; then
#			echo "Rollback on failure"
#		fi
#	fi

	echo "Deployment finished"
}


if [ $AUTO_UPDATE_ENABLED = "1" ]; then

        scriptUpdate
fi

clearBackupFolder

case "$1" in
	start)
		startServer
	;;

	stop)
		stopServer
	;;

	restart)
		stopServer
		startServer
	;;

	status)
		serverStatus
	;;

	deploy)
		deploy
	;;
esac
