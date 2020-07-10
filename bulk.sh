#!/bin/bash

# load config elements
source clogger.cfg
source "$contest"
myskcc="18144T"
logfile="./logs/bulklog.adi"

logqso() {
  echo "<CALL:${#dxcall}>$dxcall" | tr '[:lower:]' '[:upper:]' >> "$logfile"
  echo "   <BAND:${#band}>$band" | tr '[:lower:]' '[:upper:]' >> "$logfile"
  echo "   <FREQ:${#mhz}>$mhz" | tr '[:lower:]' '[:upper:]' >> "$logfile"
  echo "   <MODE:${#mode}>$mode" | tr '[:lower:]' '[:upper:]' >> "$logfile"
  echo "   <QSO_DATE:${#date}>$date" | tr '[:lower:]' '[:upper:]' >> "$logfile"
  echo "   <TIME_ON:${#timeon}>$timeon" | tr '[:lower:]' '[:upper:]' >> "$logfile"
  echo "   <OPERATOR:${#decall}>$decall" | tr '[:lower:]' '[:upper:]' >> "$logfile"
  echo "   <RST_SENT:${#sentrs}>$sentrs" | tr '[:lower:]' '[:upper:]' >> "$logfile"
  echo "   <RST_RCVD:${#recvrs}>$recvrs" | tr '[:lower:]' '[:upper:]' >> "$logfile"
  echo "   <COMMENT:${#comments}>$comments" | tr '[:lower:]' '[:upper:]' >> "$logfile"
  if [ ! -z "$skcc" ]
  then 
      echo "   <SKCC:${#skcc}>$skcc" | tr '[:lower:]' '[:upper:]' >> "$logfile"
      echo "   <MY_SKCC:${#myskcc}>$myskcc" | tr '[:lower:]' '[:upper:]' >> "$logfile"
  fi
  echo "<EOR>" | tr '[:lower:]' '[:upper:]' >> "$logfile"
}

decall="KK0ECT"
band="20M"
mode="CW"
timeon=$(date -u +%H%M)
sentrs="599"
recvrs="599"

while true
do
clear
timeon=$(date -u +%H%M)
skcc=""
dxcall=""
read -e -i "$dxcall" -p "dxcall: " input
dxcall="${input:-$dxcall}"
worked=""
worked=$(grep -i -A 9 $dxcall ./logs/complete_log.adi | grep 'CALL\|DATE\|COMMENT' | tail -3 | cut -d'>' -f2)
if [ ! -z "$worked"  ]
then
  notify-send "$worked"
fi
read -e -i "$band" -p "band: " input
band="${input:-$band}"
read -e -i "$mhz" -p "mhz: " input
mhz="${input:-$mhz}"
date=$(date -u +"%Y%m%d")
read -e -i "$date" -p "date: " input
date="${input:-$date}"
read -e -i "$timeon" -p "time: " input
timeon="${input:-$timeon}"
read -e -i "$sentrs" -p "sent rst: " input
sentrs="${input:-$sentrs}"
read -e -i "$recvrs" -p "recv rst: " input
recvrs="${input:-$recvrs}"
read -p "comment: " comments
if [[ "$comments" == *"skcc"* ]]; then
	skcc=$(awk -F 'skcc' '{print $2}' <<< "$comments")
	skcc=$(echo "$skcc" | tr -d' ')
fi
logqso
done
