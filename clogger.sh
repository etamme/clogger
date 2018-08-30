#!/bin/bash
# set field names i.e. shell variables
decall="MY0CAL"
dxcall=""
frequency="14.0"
date=$(date -u +"%Y%m%d")
starttime=$(date -u +%H%M)
sentrs="599"
recvrs="599"
contest=""
comments=""
logfile="qso.adi"
exchange="COUNTY"
txid="0"
mode="CW"
sentx="N/A"
recvx="N/A"
recvx="20M"
band="20m"
spot=0

# field positioning defaults
height=10
lx=1
fx=12
fl=0

#label defauilts
ok="OK"

function search {
dxcall=`dialog --title "CLogger" --clear --inputbox "Search for DX Call\n" 16 51 2`

}

function printData {
  dialog --clear --title "CLogger" \
        --menu "Confirm QSO data:" 20 51 10 \
        "DE CALL:"  "$decall" \
        "DX CALL:" "$dxcall" \
        "BAND:" "$band" \
        "FREQ:" "$frequency" \
        "DATE:" "$date" \
        "TIME"  "$datetime" \
        "SENT RS:"  "$sentrs" \
        "RECV RS:"  "$recvrs" \
        "COMMENTS"  "$comments"

  case $? in
    0)
      echo "Yes chosen."
      saveData;;
    1)
      echo "No chosen.";;
    255)
      echo "ESC pressed.";;
  esac

}

function saveData {
  echo "<CALL:${#dxcall}>$dxcall" | tr '[:lower:]' '[:upper:]' >> "$logfile"
  echo "   <BAND:${#band}>$band" | tr '[:lower:]' '[:upper:]' >> "$logfile"
  echo "   <FREQ:${#frequency}>$frequency" | tr '[:lower:]' '[:upper:]' >> "$logfile"
  echo "   <MODE:${#mode}>$mode" | tr '[:lower:]' '[:upper:]' >> "$logfile"
  echo "   <QSO_DATE:${#date}>$date" | tr '[:lower:]' '[:upper:]' >> "$logfile"
  echo "   <TIME_ON:${#starttime}>$datetime" | tr '[:lower:]' '[:upper:]' >> "$logfile"
  echo "   <OPERATOR:${#decall}>$decall" | tr '[:lower:]' '[:upper:]' >> "$logfile"
  echo "   <RST_SENT:${#sentrs}>$sentrs" | tr '[:lower:]' '[:upper:]' >> "$logfile"
  echo "   <RST_RCVD:${#recvrs}>$recvrs" | tr '[:lower:]' '[:upper:]' >> "$logfile"
  echo "   <COMMENT:${#comments}>$comments" | tr '[:lower:]' '[:upper:]' >> "$logfile"
  echo "<EOR>" | tr '[:lower:]' '[:upper:]' >> "$logfile"
}

function postSpot {
  freq="$frequency"
  tmp=$(echo "$freq" | sed 's/\.//')
  if [ ${#tmp} -eq 6 ];
  then
    freq=$(echo "$tmp" | sed 's/.$/.&/')
  elif [ ${#tmp} -eq 7 ];
  then
    freq=$(echo "$tmp" | sed 's/..$/.&/')
  else
    freq=$(echo "$freq" | sed 's/\.//')
  fi
   ( exec ./spot.sh "DX:$dxcall FREQ:$freq COMM:$comments"  )
}

function getData {
  dxcall=""
  dxcall=`dialog --stdout --trim --ok-label $ok --backtitle "QSO Console Logger" --title "CLogger" --form "QSO" $height 50 0 "QSO DX:" 1 $lx "$dxcall" 1 $fx 10 0`

  if grep -Fxq "$dxcall" "$logfile"
  then
   dialog --msgbox "duplicate DX call"  10 25
  fi
  frequency=`dialog --stdout --trim --ok-label $ok --backtitle "QSO Console Logger" --title "CLogger" --form "QSO" $height 50 0 "QSO FREQ:" 1 $lx "$frequency" 1 $fx 10 0`
  band=`dialog --stdout --trim --ok-label $ok --backtitle "QSO Console Logger" --title "CLogger" --form "QSO" $height 50 0 "QSO BAND:" 1 $lx "$band" 1 $fx 10 0`

  date=$(date -u +"%Y%m%d")
  starttime=$(date -u +%H%M)
  datetime="$starttime"
  datetime=`dialog --stdout --trim --ok-label $ok --backtitle "QSO Console Logger" --title "CLogger" --form "QSO" $height 50 0 "QSO TIME:" 1 $lx "$datetime" 1 $fx 20 0`
#  starttime=`dialog --stdout --trim --ok-label $ok --backtitle "QSO Console Logger" --title "CLogger" --form "QSO" $height 50 0 "QSO FREQ:" 1 $lx "$starttime" 1 $fx 10 0`
  sentrs=`dialog --stdout --trim --ok-label $ok --backtitle "QSO Console Logger" --title "CLogger" --form "QSO" $height 50 0 "SENT RS:" 1 $lx "$sentrs" 1 $fx 10 0`
  recvrs=`dialog --stdout --trim --ok-label $ok --backtitle "QSO Console Logger" --title "CLogger" --form "QSO" $height 50 0 "RECV RS:" 1 $lx "$recvrs" 1 $fx 10 0`
  #comments=""
  comments=`dialog --stdout --trim --ok-label $ok --backtitle "QSO Console Logger" --title "CLogger" --form "QSO" $height 50 0 "COMMENTS:" 1 $lx "$comments" 1 $fx 10 0`

}

while [ 1 ]
do
  getData
  printData
  if [ "$spot" -eq 1 ]; then
    postSpot
  fi
done
