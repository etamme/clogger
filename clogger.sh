#!/bin/bash
# set field names i.e. shell variables
decall="YOURCALL"
dxcall=""
frequency="14250"
date=$(date -u +"%Y-%m-%d")
starttime=$(date -u +%R)
sentrs="59"
recvrs="59"
contest=""
comments=""
logfile="clogger.log"
exchange="LAR"
txid=""

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
        "FREQ:" "$frequency" \
        "DATE:" "$date" \
        "TIME"  "$starttime" \
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
  echo "QSO:  $frequency $mode $datetime $decall $sentrst $exchange $dxcall $recvrst $comments $txid" >> "$logfile"
}

function getData {
  dxcall=""
  dxcall=`dialog --stdout --trim --ok-label $ok --backtitle "QSO Console Logger" --title "CLogger" --form "QSO" $height 50 0 "QSO DX:" 1 $lx "$dxcall" 1 $fx 10 0`

  if grep -Fxq "$dxcall" "$logfile"
  then
   dialog --msgbox "duplicate DX call"  10 25
  fi
  frequency=`dialog --stdout --trim --ok-label $ok --backtitle "QSO Console Logger" --title "CLogger" --form "QSO" $height 50 0 "QSO FREQ:" 1 $lx "$frequency" 1 $fx 10 0`

  date=$(date -u +"%Y-%m-%d")
  starttime=$(date -u +%R)
  datetime="$date $starttime"
  datetime=`dialog --stdout --trim --ok-label $ok --backtitle "QSO Console Logger" --title "CLogger" --form "QSO" $height 50 0 "QSO DATE:" 1 $lx "$datetime" 1 $fx 20 0`
#  starttime=`dialog --stdout --trim --ok-label $ok --backtitle "QSO Console Logger" --title "CLogger" --form "QSO" $height 50 0 "QSO FREQ:" 1 $lx "$starttime" 1 $fx 10 0`
  sentrs=`dialog --stdout --trim --ok-label $ok --backtitle "QSO Console Logger" --title "CLogger" --form "QSO" $height 50 0 "SENT RS:" 1 $lx "$sentrs" 1 $fx 10 0`
  recvrs=`dialog --stdout --trim --ok-label $ok --backtitle "QSO Console Logger" --title "CLogger" --form "QSO" $height 50 0 "SENT RS:" 1 $lx "$recvrs" 1 $fx 10 0`
  comments=`dialog --stdout --trim --ok-label $ok --backtitle "QSO Console Logger" --title "CLogger" --form "QSO" $height 50 0 "COMMENTS:" 1 $lx "$comments" 1 $fx 10 0`
}

while [ 1 ]
do
  getData
  printData
done
