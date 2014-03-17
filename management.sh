#!/bin/bash

## management.sh
# Version: 0.1.5-SNAPSHOT
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
	                echo "Update succesful > restart script"
	                source $(dirname $(readlink -f $0))/management.sh
	                exit 1;
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

        if [ ! -f $1 ]; then
        	echo "$1 not found"
        	echo "Deployment aborted"
        	exit 1;
        fi

#	if [ ! -d $WEBAPPS_FOLDER ]; then
#		echo "$WEBAPPS_FOLDER not found"
#		echo "Deployment aborted"
#		exit 1;
#	fi

	stopServer

	if [ ! -d $WAR_BACKUP_FOLDER ]; then
		mkdir -p $WAR_BACKUP_FOLDER
		echo "Backup-folder created"
	fi

	if [ -f "$CURRENT_WAR" ]; then
		cp "$CURRENT_WAR" "$WAR_BACKUP_FOLDER$(date +"%Y-%m-%d-%H:%M").war"
		mv "$CURRENT_WAR" "$WAR_BACKUP_FOLDERlatest.war"
		echo "Old war saved"
	fi

	rm -f "$CURRENT_WAR"
	echo "Current war removed"

	mv $1 "$CURRENT_WAR"
	echo "New war moved"

	startServer
	echo "Deployment finished"
}

function rollback {
	if [ ! -f "$WAR_BACKUP_FOLDERlatest.war" ]; then
		echo "latest.war not found"
		echo "Rollback aborted"
		exit 1;
	fi

	deploy "$WAR_BACKUP_FOLDERlatest.war"
	echo "Rollback finished"
}


if [ "$AUTO_UPDATE_ENABLED" = "1" ]; then
        scriptUpdate
fi

case "$1" in
	startServer)
		startServer
	;;

	stopServer)
		stopServer
	;;

	restartServer)
		stopServer
		startServer
	;;

	status)
		serverStatus
	;;

	deploy)
		if [ ! -z $2 ]; then
			deploy $2
		else
			deploy "$NEW_WAR"
		fi

		clearBackupFolder
	;;

	rollback)
		rollback
	;;

	*)
		echo "Usage:"
		echo "	*.sh startServer"
		echo "	*.sh stopServer"
		echo "	*.sh restartServer"
		echo "	*.sh status"
		echo "	*.sh deploy"
		echo "	*.sh deploy any.war"
		echo "	*.sh rollback"
	;;
esac
