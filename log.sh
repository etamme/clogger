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
}

# takes a single argument of the keyvalue (from readkey)
# designed to be called using command substitution
# e.g.:  mappedkey=$(mapkey "$key")
mapkey() {
  echo "-$1-" >> log.log
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
    " ") echo "space";;
    "	") echo "tab";;
    *) echo "$1";;
  esac
}

menu() {
  lines=0
  tput clear
  tput bold
  echo "Mode: $logmode  Speed: $speed"
  tput sgr0
  # build the function map for the menu
  for i in {1..9}
  do
    f="f$i"
    func="$logmode$f"
    if [ -n "$(type -t ${!func})" ] && [ "$(type -t ${!func})" = function ]
    then
      let lines+=1 
      echo -e "$f: ${!func}"
    fi
  done

  echo "Last operation: $status"
  echo -n ">$buff"
  let lines+=2
}

# this expects the keyname as arg1, and the logmode as arg2
# these functions are mapped in log.cfg in the function map section
# if no function is found, the key appendbuff is called
execfunc() {
  echo "KEY:$1: MODE:$2:" >> log.log
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
  $keyer -w $speed -d $cwdevice -t "$1"
}

qrq() {
  let speed+=5
  menu
}
qrs() {
  let speed-=5
  menu
}
runqrq=qrq
sandpqrq=qrq
runqrs=qrs
sandpqrs=qrs

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
  status="QSO logged"
  menu
}

send_tu_exchange_logqso() {
  sendtu
  sendexchange
  logqso
  clearbuff
}

send_buff_exchange() {
  sendbuff
  sendexchange
}

send_tu_logqso_cq() {
  sendtu
  logqso
  sendcq
  clearbuff
}

togglemode() {
  if [[ "$logmode" == "run" ]]
  then 
    logmode="sandp"
  else
    logmode="run"
  fi
  menu
}

runenter() {
  sendbuff
}

sandpenter() {
  sendbuff
}

tab() {
  status="TAB"
}
runtab=tab
sandptab=tab

space() {
  appendbuff " "
}
runspace=space
sandpspace=space

clearbuff() {
  buff=""
  tput el1
  tput cup $lines 0
  echo -n ">$buff"
}

backspace() {
  if [[ ! -z "$buff" ]]
  then
    buff="${buff:0:-1}"
    tput el1
    tput cup $lines 0
    echo -n ">$buff"
  fi
}
runback="backspace"
sandpback="backspace"

# takes a single argument of the text to append to buff
appendbuff() {
  buff="$buff$1"
  tput el1
  tput cup $lines 0
  echo -n ">$buff"
}

mainloop() {
  buff=""
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
