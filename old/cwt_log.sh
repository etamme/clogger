#! /bin/bash

band="20m"
frequency="14.038"
mode="cw"
date=$(date -u +"%Y%m%d")
time=$(date -u +%H%M)
decall="KK0ECT"
sentrs="599"
recvrs="599"
comments=""
logfile="qso.adi"

filename="calls"
calls=""
while read -r line
do
    calls="$calls $line"
done < "$filename"

function saveData {
  echo "<CALL:${#dxcall}>$dxcall" | tr '[:lower:]' '[:upper:]' >> "$logfile"
  echo "   <BAND:${#band}>$band" | tr '[:lower:]' '[:upper:]' >> "$logfile"
  echo "   <FREQ:${#frequency}>$frequency" | tr '[:lower:]' '[:upper:]' >> "$logfile"
  echo "   <MODE:${#mode}>$mode" | tr '[:lower:]' '[:upper:]' >> "$logfile"
  echo "   <QSO_DATE:${#date}>$date" | tr '[:lower:]' '[:upper:]' >> "$logfile"
  echo "   <TIME_ON:${#time}>$time" | tr '[:lower:]' '[:upper:]' >> "$logfile"
  echo "   <OPERATOR:${#decall}>$decall" | tr '[:lower:]' '[:upper:]' >> "$logfile"
  echo "   <RST_SENT:${#sentrs}>$sentrs" | tr '[:lower:]' '[:upper:]' >> "$logfile"
  echo "   <RST_RCVD:${#recvrs}>$recvrs" | tr '[:lower:]' '[:upper:]' >> "$logfile"
  echo "   <COMMENT:${#comments}>$comments" | tr '[:lower:]' '[:upper:]' >> "$logfile"
  echo "<EOR>" | tr '[:lower:]' '[:upper:]' >> "$logfile"
}

while [ 1 ]
do
  dxcall=$(rlwrap -S 'Call: ' -e '' -i -f <(echo "${calls[@]}") -o cat)
  read -p "Name and number: " comments
  saveData
  clear
done
