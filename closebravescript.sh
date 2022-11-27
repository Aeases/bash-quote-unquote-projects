#!/bin/bash
directory=$(pwd)
export DISPLAY=:0
export GNOME_DESKTOP_SESSION_ID=0
requirdependancy=("zenity")
### Checking Depenancies from ^^^^
for i in "${requirdependancy[@]}"
do
	if ! [ -x "$(command -v $i)" ] 
		then
		echo "ERROR $i not Installed"
		exit 1
fi
done

function main() {
file=closebravescript.sh
ie=1

while [ -f "$file" ]
do
	killall brave
	if [ $? -eq 0 ]; then
	zenity --warning --text "get annoyed" --title "$directory" --width 600
	fi
done
while [ $ie -lt 3 ];
do
	notify-send -u critical "$directory" "ERROR DOES NOT EXIST" -t 2000
	let "ie=ie+1"
	echo "hi"
done
}
main"$@"

