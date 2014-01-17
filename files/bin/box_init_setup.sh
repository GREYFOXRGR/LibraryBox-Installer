#!/bin/sh

### Initial Setup script for:
##      - setting password
##      - Date & Time with userinput
##            => initialize timesave script if available.

DEBUG=false
TIMESAVE_SCRIPT="/opt/piratebox/bin/timesave.sh"

FTP_CONFIG_SCRIPT="/opt/piratebox/bin/ftp_enable.sh"
FTP_CONFIG_AVAILABLE="-e $FTP_CONFIG_SCRIPT"

mainmenu() {


	while  true  
	do
		echo "-------------------------------------"
		echo " " 
		echo "   1 - Setting password and enable SSH"
		echo "   2 - Set date & time (enable timesave)"
		if [ $FTP_CONFIG_AVAILABLE ] ; then
			echo "   3 - Start FTP configuration "
		else
			echo "     - FTP configuration not available"
		fi
		echo ""
		echo " Everything else causes an exit"
		echo " "
		read -p " Choose an option: " option

		case $option in 
			("1")  _set_password_ ;;
			("2")  _set_date_ ;;
			("3")  _start_ftp_config_ ;;
			(*) exit 0;;
		esac
		option=""
	done
}

_set_password_() {

	echo "Please enter your password. The following command won't show you the entered letters."
	local cmd=passwd
	if  [ "$DEBUG" = "false" ]  ; then
		$cmd  && echo "$? ....OK" 
	else
		echo "$cmd"
	fi

}

_set_date_() {

	local year=""
	local time_=""

	read -p "Please enter your date in the format  YYYYMMDD : " year
	read -p "Please enter your time in the format  HHMM : " time_
	datetime="$year""$time_"
	local cmd="date $datetime"
	if  [ $DEBUG = "false" ]  ; then 
		$cmd && echo "... OK"
	else
		echo "$cmd"
	fi
	# If timesave script is available, and it is not already installed, install it.
	if [ -e $TIMESAVE_SCRIPT ] ; then
		if  ! crontab -l | grep -q timesave.sh  ; then
			 $TIMESAVE_SCRIPT  /opt/piratebox/conf/piratebox.conf install
			# Create OpenWRT cron-enabling and insert into rc.local
			/etc/init.d/piratebox timesave
		else
			 $TIMESAVE_SCRIPT  /opt/piratebox/conf/piratebox.conf save
		fi
	fi
}

_start_ftp_config_() {

	if [ $FTP_CONFIG_AVAILABLE ] ; then
	 	. $FTP_CONFIG_SCRIPT
	else
		echo "FTP configuration not available"
	fi
	return 0

}


mainmenu
