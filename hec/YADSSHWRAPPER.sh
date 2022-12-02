#!/bin/bash
export DISPLAY=:0
export GNOME_DESKTOP_SESSION_ID=0
path=$(pwd)
logfile=$path/.ipfinderyad-logfile.log
#rm $logfile
fkey="$RANDOM"
screenuuid=$(cat /proc/sys/kernel/random/uuid); screenuuid="ipfinderyad$screenuuid"

requirdependancy=("watch" "yad" "screen")
### Checking Depenancies from ^^^^
for i in "${requirdependancy[@]}"
do
	if ! [ -x "$(command -v $i)" ] 
		then
		echo "ERROR $i not Installed"
		exit 1
fi
done


function main () {
row=$(yad --form --title "Location Finder" --text="Required Information" --borders=10 --fixed --no-escape --center --on-top \
	--field="IP" \
	--field="Username"); echo $row
if [[ "$row" == "|" ]] # Check if no data was entered
then
	yad --info --text "No Data Entered."
	exit 1
fi

if [[ -n $row ]] # was any data entered??
then
	indata=$(echo "'$row'" | sed "s/|/','/g")
	IFS="'"
	read -r -a array <<< "$indata"
else
	yad --warning --title="Error" --text "Cancelled"
	exit 1
fi

# Checking IP Validity
if ipinvalid "${array[1]}"
then
	yad --warning --text "INVALID IP"
	exit 1
fi





#espeak "$path"
screen -dmS $screenuuid
screen -S $screenuuid -p 0 -X stuff "ssh "${array[3]}@${array[1]}" -v &> $logfile^M"
#screen -S $screenuuid -p 0 -X 

sshprogress
}

sshprogress() {
(
echo "5"
OUTPUT=$(tail -n 1 $logfile)
#espeak "$OUTPUT"
#sleep 10
OUTPUT=$(tail -n 1 $logfile)
echo "# $OUTPUT"
while ! [[ "$OUTPUT" =~ "denied"|"Timed Out"|"No route to host"|"debug1: Next authentication method: password" ]]
do 
	echo "# $OUTPUT"
	espeak "OUTPUTTED"
	echo "30"
	OUTPUT=$(tail -n 1 $logfile)
done
echo "# $OUTPUT"
sleep 1
OUTPUT=$(tail -n 1 $logfile)
) | yad --progress --pulsate --title="Secure Shell" --text="Connecting" --button gtk-cancel:1 --width 150 --height 100 --auto-close
OUTPUT=$(tail -n 1 $logfile)
if [[ "$OUTPUT" =~ "debug1: Next authentication method: password" ]]; then
	echo "100"
	secureshellconnection
fi

}

secureshellask () {
if [[ $1 -gt 13 ]]; then
	espeak "Too many incorrect attempts"
	handler
fi
sshpass=$(yad --entry --border=10\
--title="Shell Password" \
--text="Enter Password of remote computer" \
--hide-text)
espeak "$sshpass"
echo "$sshpass"
screen -S $screenuuid -p 0 -X stuff "$sshpass^M"
(
	counter=0
	for i in {1..20}; do
		echo $counter
		echo $(OUTPUT=$(tail -n 1 $logfile))
		counter=$(($counter + 5))
		sleep 0.15
	done
) | yad --progress --title "Initiating Connection" --text "Connecting" --auto-close
OUTPUT=$(tail -n 1 $logfile)
espeak "$OUTPUT"
if [[ "$OUTPUT" =~ "Permission denied" ]]
then
	((success=success+1))
	espeak "Failed $success"
else
	((success=1))
	espeak "Passed $success"
fi
}



secureshellconnection() {
export success=10
while [[ $success -ge 10 ]]; do
	espeak "$success"
	secureshellask "$success"
done
espeak "finally done"
(
	counter=0
	for i in {1..20}; do
		echo $counter
		echo $(OUTPUT=$(tail -n 1 $logfile))
		counter=$(($counter + 5))
		sleep 0.15
	done
) | yad --progress --title "Communicating" --text "Communicating" --auto-close



espeak "Here is $OUTPUT"
#screen -S $screenuuid -p 0 -X stuff "$sshpass^M"
espeak "shut the fuck up"
yad --plug="$fkey" --tabnum="1" --form --text "Enter Command" --field=$"Command:" --field "Button:BTN" "" "screen -S $screenuuid -p 0 -X stuff '%1^M'" &
(
#while [[ $(tail -n 1 $logfile) == $OUTPUT ]]; do 
while [ -f $logfile ]; do
OUTPUTNEW=$(tail -n 1 $logfile)
if ! [[ "$OUTPUTNEW" == "$OUTPUT" ]]; then
	echo $OUTPUTNEW
	OUTPUT=$(tail -n 1 $logfile)
fi
OUTPUT=$(tail -n 1 $logfile)
done
) | yad	--plug="$fkey" --tabnum="2" --tail --text-info &
yad --paned --key="$fkey" --title="Panel 2 x 2" --width 500 --height 500
sleep 2
}



















ipinvalid() {
  # Set up local variables
  local ip=${1:-NO_IP_PROVIDED}
  local IFS=.; local -a a=($ip)
  # Start with a regex format test
  [[ $ip =~ ^[0-9]+(\.[0-9]+){3}$ ]] || return 0
  # Test values of quads
  local quad
  for quad in {0..3}; do
    [[ "${a[$quad]}" -gt 255 ]] && return 0
  done
  return 1
}





handler() {
	reason=$1
	echo "Processing the Ctrl+C"
	screen -XS $screenuuid quit
	echo "$logfile"
	rm $logfile
	espeak "$1"
	exit 1
}
trap handler SIGINT
main "$@"
echo "$logfile"
rm $logfile
screen -XS $screenuuid quit
exit
