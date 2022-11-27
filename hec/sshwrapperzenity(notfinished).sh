#!/bin/bash
export DISPLAY=:0
export GNOME_DESKTOP_SESSION_ID=0
path=$(pwd)
logfile=$path/.ipfinder-logfile.log
rm $logfile
requirdependancy=("watch" "zenity")
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
row=$(zenity --forms --title "Location Finder" --text="Required Information" \
	--add-entry="IP" \
	--add-entry="Username"); echo $row
if [[ "$row" == "|" ]] # Check if no data was entered
then
	zenity --info --text "No Data Entered."
	exit 1
fi

if [[ -n $row ]] # was any data entered??
then
	indata=$(echo "'$row'" | sed "s/|/','/g")
	IFS="'"
	read -r -a array <<< "$indata"
else
	zenity --warning --title="Error" --text "Cancelled"
	exit 1
fi

# Checking IP Validity
if ipinvalid "${array[1]}"
then
	zenity --warning --text "INVALID IP"
	exit 1
fi




screenuuid=$(cat /proc/sys/kernel/random/uuid); screenuuid="ipfinder$screenuuid"
#espeak "$path"
screen -dmS $screenuuid
screen -S $screenuuid -p 0 -X stuff "ssh "${array[3]}@${array[1]}" -v &> $logfile^M"
#screen -S $screenuuid -p 0 -X 

sshprogress
}

sshprogress() {
(
OUTPUT=$(tail -n 1 $logfile)
espeak "$OUTPUT"
#sleep 10
OUTPUT=$(tail -n 1 $logfile)
echo "# $OUTPUT"
espeak "this is the $OUTPUT"
while ! [[ "$OUTPUT" =~ "denied"|"Timed Out"|"No route to host"|"debug1: Next authentication method: password" ]]
do 
	echo "# $OUTPUT"
	espeak "OUTPUTTED"
	OUTPUT=$(tail -n 1 $logfile)
done
echo "# $OUTPUT"
sleep 1
OUTPUT=$(tail -n 1 $logfile)
if [[ "$OUTPUT" =~ "debug1: Next authentication method: password" ]]; then
	secureshellconnection
fi
) | 
zenity --progress \
--title="Secure Shell" \
--text="Connecting" \
--pulsate
}


secureshellconnection() {
sshpass=$(zenity --password \
--title="Shell Password" \
--text="Enter Password of remote computer")
espeak "$sshpass"
screen -S $screenuuid -p 0 -X $sshpass
sleep 3
OUTPUT=$(tail -n 1 $logfile)
espeak "$OUTPUT"
screen -S $screenuuid -p 0 -X stuff "$sshpass^M"
#while true; do
	zenity --text-info \
	--title="${array[3]}'s Shell" \
	--filename=$logfile
sleep 10
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
	echo "Processing the Ctrl+C"
	screen -XS $screenuuid quit
	espeak "hi"
	echo "$logfile"
	rm $logfile
	exit 1
}
trap handler SIGINT
main "$@"
echo "$logfile"
rm $logfile
screen -XS $screenuuid quit
exit
