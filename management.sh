#!/bin/bash

wget "https://raw.github.com/jewm/jasdh/master/management.sh" -O "management.sh"
rm "management.sh"
mv "download.sh" "management.sh"
chmod +x "management.sh"
./management.sh


case "$1" in
	start)
		echo "Starting server..."
		$APPLICATION_SERVER_START
		echo "Server started"
	;;

	stop)
		echo "Stopping server..."
		$APPLICATION_SERVER_STOP
		echo "Server stopped"
	;;

	restart)
		$0 stop
		$0 start
	;;

	status)
		$APPLICATION_SERVER_STATUS
	;;

	deploy)
		echo "Start deployment"

		if [ ! -f "$WAR_PATH$CURRENT_WAR_NAME" ]; then
			echo "$CURRENT_WAR_NAME not found"
			echo "Deployment aborted"
			exit 1;
		fi

		$0 stop

		if [ ! -d $WAR_BACKUP_PATH ]; then
			mkdir -p $WAR_BACKUP_PATH
			echo "Backup-folder created"
		fi

		if [ -f "$WEBAPPS_PATH$FINAL_WAR_NAME" ]; then
			mv "$WEBAPPS_PATH$FINAL_WAR_NAME" "$WAR_BACKUP_PATH$(date +"%Y-%m-%d-%H:%M").war"
			echo "Old war saved"
		fi

		rm -rf "$WEBAPPS_PATH*"
		echo "Webapps-folder cleared"

		cp "$WAR_PATH$CURRENT_WAR_NAME" "$WEBAPPS_PATH$FINAL_WAR_NAME"
		echo "New war moved"

		if [ "$2" = "--auto-rollback" ]; then
			echo "Rollback on failure"
		fi

		$0 start

		if [ ! $APPLICATION_RUNNING ]; then
			if [ "$2" = "--auto-rollback" ]; then
                        	echo "Rollback on failure"
                	fi
		fi

		echo "Deployment finished"
	;;
esac
