#!/bin/bash

# load config elements
source clogger.cfg
source "$contest"
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
  echo "<EOR>" | tr '[:lower:]' '[:upper:]' >> "$logfile"
}

decall="$mycall"
band="20M"
mode="CW"
date=$(date -u +"%Y%m%d")
timeon=$(date -u +%H%M)
sentrs="599"
recvrs="599"

while true
do
clear
dxcall=""
read -e -i "$dxcall" -p "dxcall: " input
dxcall="${input:-$dxcall}"
read -e -i "$band" -p "band: " input
band="${input:-$band}"
read -e -i "$mhz" -p "mhz: " input
mhz="${input:-$mhz}"
read -e -i "$date" -p "date: " input
date="${input:-$date}"
read -e -i "$timeon" -p "time: " input
timeon="${input:-$timeon}"
read -e -i "$sentrs" -p "sent rst: " input
sentrs="${input:-$sentrs}"
read -e -i "$recvrs" -p "recv rst: " input
recvrs="${input:-$recvrs}"
read -p "comment: " comments
logqso
done
