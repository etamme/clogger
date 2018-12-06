#!/bin/bash

# load config elements
source log.cfg

# This function reads keys, including special function keys
readkey() {
  local key settings
  settings=$(stty -g)             # save terminal settings
  stty -icanon -echo min 0        # disable buffering/echo, allow read to poll
  dd count=1 > /dev/null 2>&1     # Throw away anything currently in the buffer
  stty min 1                      # Don't allow read to poll anymore
  key=$(dd count=1 2> /dev/null)  # do a single read(2) call
  stty "$settings"                # restore terminal settings
  printf "%s" "$key"
}

# Use tput to support portable multi char keypresses
# TERM has to be set correctly for this to work.
initkeys() {
  tput init
  f1=$(tput kf1)
  f2=$(tput kf2)
  f3=$(tput kf3)
  f4=$(tput kf4)
  f5=$(tput kf5)
  f6=$(tput kf6)
  f7=$(tput kf7)
  f8=$(tput kf8)
  f9=$(tput kf9)
  f10=$(tput kf10)
  back=$(tput kbs)
  enter=$(tput nel)
  escape=$'\e'
  tab=$'\t'
}

# takes a single argument of the keyvalue (from readkey)
# designed to be called using command substitution
# e.g.:  mappedkey=$(mapkey "$key")
mapkey() {
  case "$1" in
    "$f1") echo "f1";;
    "$f2") echo "f2";;
    "$f3") echo "f3";;
    "$f4") echo "f4";;
    "$f5") echo "f5";;
    "$f6") echo "f6";;
    "$f7") echo "f7";;
    "$f8") echo "f8";;
    "$f9") echo "f9";;
    "$enter") echo "enter";;
    "$back") echo "back";;
    "$escape") echo "escape";;
    "$tab") echo "tab";;
    " ") echo "space";;
    *) echo "$1";;
  esac
}



# this expects the keyname as arg1, and the logmode as arg2
# these functions are mapped in log.cfg in the function map section
# if no function is found, the key appendbuff is called
execfunc() {
  # create a named function based on the key and mode
  func="$2$1"
  if [[ "$func" =~ ^[[:alnum:]]*$ ]] && [ -n "$(type -t ${!func})" ] && [ "$(type -t ${!func})" = function ]
  then
    ${!func}
  else
    appendbuff "$1"
  fi
}

# arg1: text
cwsend() {
  if [[ ! -z $1 ]]
  then
    lastaction="$1"
    drawlastaction
    $keyer -w $speed -d $cwdevice -t "$1" &
  fi
}

qrq() {
  speed="$(($speed+5))"
  drawstatus
}
qrs() {
  speed="$(($speed-5))"
  drawstatus
}
runqrq=qrq
sandpqrq=qrq
runqrs=qrs
sandpqrs=qrs

getcall() {
  local val=$(echo "$buff" | cut -d' ' -f1)
  echo "$val"
}

gete1() {
  local val=$(echo "$buff" | cut -d' ' -f2)
  echo "$val"
}

# these are the defined functions that you can map f1-f9 to for each mode
sendbuff() {
 cwsend "$buff"
}

sendcq() {
 cwsend "$mycq"
}

sendexchange() {
 cwsend "$myexchange"
}

sendmycall() {
 cwsend "$mycall"
}
sendtu() {
  cwsend "TU"
}
sendagn() {
 cwsend "$myagn"
}

logqso() {
  dxcall=$(echo "$buff" | cut -d' ' -f1)
  decall="$mycall"
  band="20M"
  mode="CW"
  date=$(date -u +"%Y%m%d")
  timeon=$(date -u +%H%M)
  sentrs="599"
  recvrs="599"
  comments=$(echo "$buff" | cut -d' ' -f2-)
  echo "<CALL:${#dxcall}>$dxcall" | tr '[:lower:]' '[:upper:]' >> "$logfile"
  echo "   <BAND:${#band}>$band" | tr '[:lower:]' '[:upper:]' >> "$logfile"
  echo "   <FREQ:${#frequency}>$frequency" | tr '[:lower:]' '[:upper:]' >> "$logfile"
  echo "   <MODE:${#mode}>$mode" | tr '[:lower:]' '[:upper:]' >> "$logfile"
  echo "   <QSO_DATE:${#date}>$date" | tr '[:lower:]' '[:upper:]' >> "$logfile"
  echo "   <TIME_ON:${#timeon}>$timeon" | tr '[:lower:]' '[:upper:]' >> "$logfile"
  echo "   <OPERATOR:${#decall}>$decall" | tr '[:lower:]' '[:upper:]' >> "$logfile"
  echo "   <RST_SENT:${#sentrs}>$sentrs" | tr '[:lower:]' '[:upper:]' >> "$logfile"
  echo "   <RST_RCVD:${#recvrs}>$recvrs" | tr '[:lower:]' '[:upper:]' >> "$logfile"
  echo "   <COMMENT:${#comments}>$comments" | tr '[:lower:]' '[:upper:]' >> "$logfile"
  echo "<EOR>" | tr '[:lower:]' '[:upper:]' >> "$logfile"
  qsocount="$(($qsocount+1))"
  serial="$(($serial+1))"
  menu
}

send_tu_exchange_logqso() {
  cwsend "TU $myexchange"
  logqso
  clearbuff
}

send_call_exchange() {
  local call=$(getcall)
  cwsend "$call $myexchange"
}

send_tu_logqso_cq() {
  local e1=$(gete1)
  cwsend "TU $e1 $mycq"
  logqso
  clearbuff
}

togglemode() {
  if [[ "$logmode" == "run" ]]
  then
    logmode="sandp"
  else
    logmode="run"
  fi
  clearbuff
  menu
}


#
# ------------ functions for special key bindings ---------------
#              enter, tab, backspace, escape, space
#

# in both modes, enter simply sends what is in the buffer
runenter() {
  sendbuff
}
sandpenter() {
  sendbuff
}

# kills any current keyer process to halt transmission
escape() {
  pid=""
  pid=$(pgrep -f "$keyer")
  if [[ ! -z $pid ]]
  then
    kill -9 $pid
    wait $pid 2>/dev/null
  fi
}
runescape=escape
sandpescape=escape

# auto completes the first column of the callfile if there are multiple matches
# if there is a single match, it pulls the exchange portion from the callfile
tab() {
  if [[ $(grep -i "$buff" "$callfile" | wc -l)  -eq 1 ]]
  then
    local buffexchange=$(grep -i "$buff" "$callfile" | cut -d"$delimeter" -f2-)
    local call=$(grep -i "$buff" "$callfile" | cut -d"$delimeter" -f1)
    buff="$call $buffexchange"
    subbuff=""
    menu
  else
    subbuff=$(grep -i "$buff" "$callfile" | cut -d"$delimeter" -f1)
    drawsubmenu
  fi
}
runtab=tab
sandptab=tab

# appends a space to the buffer
space() {
  appendbuff " "
}
runspace=space
sandpspace=space

# remove a char from the buffer
backspace() {
  if [[ ! -z "$buff" ]]
  then
    buff="${buff:0:-1}"
    tput el1
    tput cup $buffline 0
    echo -n ">$buff"
  fi
}
runback="backspace"
sandpback="backspace"

#
# ------------ drawing routines ---------------
#

# draw the main menu screen and calculate buffline
menu() {
  clearscreen
  tput cup $menuline 0
  buffline=0
  drawstatus
  drawlastaction
  # build the function map for the menu
  for i in {1..9}
  do
    f="f$i"
    func="$logmode$f"
    if [ -n "$(type -t ${!func})" ] && [ "$(type -t ${!func})" = function ]
    then
      let buffline+=1
      echo -e "$f: ${!func}"
    fi
  done
  let buffline+=1
  drawsubmenu
  drawbuff
}


# takes a single argument of the line number to clear
clearline() {
  tput cup $1 0
  tput el
}

drawlastaction() {
  tput sc
  clearline $lastactionline
  tput dim
  echo "Last action: $lastaction"
  tput sgr0
  tput rc 
}

# takes a single argument of the text to append to buff
appendbuff() {
  buff="$buff$1"
  tput el1
  tput cup $buffline 0
  echo -n ">$buff"
}

clearbuff() {
  buff=""
  drawbuff
}

clearscreen() {
  tput clear
}

drawbuff() {
  clearline $buffline
  tput cup $buffline 0
  echo -n ">$buff"
}

drawstatus() {
  status="Mode: $logmode  Speed: $speed Call: $mycall QSO: $qsocount"
  tput sc
  clearline $statusline
  tput bold
  echo "$status"
  tput sgr0
  tput rc
}

drawsubmenu() {
  tput sc
  let subline=$buffline+2
  tput cup $subline 0
  echo $subbuff
  tput rc
}

#
# ------------ main loop and script init ---------------
#

mainloop() {
  buff=""
  subbuff=""
  lastaction=""
  statusline=0
  lastactionline=1
  menuline=2
  qsocount=0
  menu
  while true
  do
    key=$(readkey)
    mappedkey=$(mapkey "$key")
    execfunc "$mappedkey" "$logmode"
  done
}

# we MUST initialize our keycodes
initkeys
# call our main loop
mainloop