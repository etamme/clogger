#!/bin/bash

# load config elements
#source clogger.cfg
source my.cfg
source "$contest"

# turn on or off verbose debug logs
debugon="false"
debuglog="./debug"

# This function reads keys, including special function keys
readkey() {
  debug "${FUNCNAME[0]}"
  local key settings
  settings=$(stty -g)             # save terminal settings
  stty -icanon -echo min 0        # disable buffering/echo, allow read to poll
  dd count=1 > /dev/null 2>&1     # Throw away anything currently in the buffer
  stty min 1                      # Don't allow read to poll anymore
  key=$(dd count=1 2> /dev/null)  # do a single read(2) call
  stty "$settings"                # restore terminal settings
  printf "%s" "$key"
  debug "rawkey: '$key'"
}

# Use tput to support portable multi char keypresses
# TERM has to be set correctly for this to work.
initkeys() {
  debug "${FUNCNAME[0]}"
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
  debug "${FUNCNAME[0]}"
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
    *) 
       if [[ "$1" =~ ^[[:alnum:]]*$ ]] || [[ "$1" =~ ^[[:punct:]]*$ ]]
       then
         echo "$1"
       fi
       ;;
  esac
}

debug() {
  if [[ "$debugon" == "true" ]]
  then
    echo "$1" >> "$debuglog"
  fi
}

# this expects the keyname as arg1, and the logmode as arg2
# these functions are mapped in log.cfg in the function map section
# if no function is found, the key appendbuff is called
execfunc() {
  debug "${FUNCNAME[0]}"
  # create a named function based on the key and mode
  func="$2$1"
  debug "$func"
  if [[ "$func" =~ ^[[:alnum:]]*$ ]] && [ -n "$(type -t ${!func})" ] && [ "$(type -t ${!func})" = function ]
  then
    # when running the sendcq function, run it in background and capture the pid
    if [[ "${!func}" == "sendcq" ]]
    then
      ${!func} &
      cqpid=$!
      debug "sendcq cqpid: $cqpid"
    else
      ${!func}
    fi
  else
    debug "appendbuff $1"
    appendbuff "$1"
  fi
}

killcqpid() {
  debug "${FUNCNAME[0]}"
  if [[ ! -z "$cqpid" ]]
  then
    debug "kill -9 $cqpid"
    kill -9 $cqpid
    wait $pid 2>/dev/null
    cqpid=""
  fi
}

# arg1: text arg2: async/sync (default to async)
cwsend() {
  debug "${FUNCNAME[0]}"
  if [[ ! -z $1 ]] && [[ "$usekeyer" == "true" ]]
  then
    lastaction="$1"
    drawlastaction
    if [[ "$2" == "sync" ]]
    then
      $keyer -w $speed -d $cwdevice -t "$1"
    else
      $keyer -w $speed -d $cwdevice -t "$1" &
    fi
  fi
}

qrq() {
  debug "${FUNCNAME[0]}"
  speed="$(($speed+5))"
  drawstatus
}
qrs() {
  debug "${FUNCNAME[0]}"
  speed="$(($speed-5))"
  drawstatus
}
runqrq=qrq
sandpqrq=qrq
runqrs=qrs
sandpqrs=qrs

getcall() {
  debug "${FUNCNAME[0]}"
  local val=$(echo "$buff" | cut -d' ' -f1)
  echo "$val"
}

gete1() {
  debug "${FUNCNAME[0]}"
  local val=$(echo "$buff" | cut -d' ' -f2)
  echo "$val"
}

# these are the defined functions that you can map f1-f9 to for each mode
sendbuff() {
  debug "${FUNCNAME[0]}"
  cwsend "$buff"
}

sendcq() {
  debug "${FUNCNAME[0]}"
 while true
 do
   cwsend "$mycq" "sync"
   sleep $cqdelay
 done
}

sendexchange() {
  debug "${FUNCNAME[0]}"
  cwsend "$myexchange"
}

sendmycall() {
  debug "${FUNCNAME[0]}"
  cwsend "$mycall"
}
sendtu() {
  debug "${FUNCNAME[0]}"
  cwsend "TU"
}
sendagn() {
  debug "${FUNCNAME[0]}"
  cwsend "$myagn"
}

logqso() {
  debug "${FUNCNAME[0]}"
  dxcall=$(echo "$buff" | cut -d' ' -f1)
  decall="$mycall"
  band="20M"
  mode="CW"
  date=$(date -u +"%Y%m%d")
  timeon=$(date -u +%H%M)
  sentrs="599"
  recvrs="599"
  comments=$(echo "$buff" | cut -d' ' -f2-)
#  khz=$($rigctl -m $rig -r $rigdevice "f")
#  mhz=$(bc <<< "scale = 4; ($khz/1000000)")
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
  qsocount="$(($qsocount+1))"
  serial="$(($serial+1))"
  dupe="false"
  lastaction="Logged $buff"
  drawlastaction
  clearbuff
  menu
}

send_tu_exchange_logqso() {
  debug "${FUNCNAME[0]}"
  cwsend "TU $myexchange"
  logqso
  clearbuff
}

send_call_exchange() {
  debug "${FUNCNAME[0]}"
  local call=$(getcall)
  cwsend "$call $myexchange"
}

send_tu_logqso_cq() {
  debug "${FUNCNAME[0]}"
  cwsend "TU $mycq"
  logqso
  clearbuff
}

send_tu_e1_logqso_cq() {
  debug "${FUNCNAME[0]}"
  local e1=$(gete1)
  cwsend "TU $e1 $mycq"
  logqso
  clearbuff
}

togglemode() {
  debug "${FUNCNAME[0]}"
  if [[ "$logmode" == "run" ]]
  then
    logmode="sandp"
  else
    logmode="run"
  fi
  clearbuff
  menu
}

# arg1 is call to check
checkdupe() {
  debug "${FUNCNAME[0]}"
  if fgrep -qiF "$1" "$logfile" 
  then
    echo "true"
  else
    echo "false"
  fi
}

#
# ------------ functions for special key bindings ---------------
#              enter, tab, backspace, escape, space
#
runcommand() {
  debug "${FUNCNAME[0]}"
  local prefix=$(echo "$1" | cut -d' ' -f1)
  if [[ "$prefix" == ":rig" ]]
  then
    local rigargs=$(echo "$1" | cut -d' ' -f2-)
    rigcommand "$rigargs"
    subbuff="$rigres"
    drawsubmenu
  else
    case "$prefix" in
    ":quit") echo "" && exit ;;
    ":qrs") qrs ;;
    ":qrq") qrq ;;
    ":freq") setfreq $(echo "$1" | cut -d' ' -f2) ;;
    *) buff="unknown command $prefix" && drawbuff ;;
    esac
  fi
}

rigcommand() {
  debug "${FUNCNAME[0]}"
  if [[ "$userig"  == "true" ]]
  then
    local arg1=$(echo "$1" | cut -d' ' -f1)
    rigres=$($rigctl -m $rig -r $rigdevice $1)
    clearbuff
    if [[ "$arg1" == "F" ]]
    then
      freq="$rigres"
      drawstatus
    fi
  fi
}

# arg1 is frequency
setfreq() {
  debug "${FUNCNAME[0]}"
  rigcommand "F $1"
  freq=$1
  drawstatus
}

getfreq() {
  debug "${FUNCNAME[0]}"
  rigcommand "f"
  freq="$rigres" 
}

# in both modes, enter simply sends what is in the buffer
enter() {
  debug "${FUNCNAME[0]}"
  if [[ "${buff:0:1}" == ":" ]]
  then
    runcommand "$buff"
  else
    sendbuff
  fi
}
runenter=enter
sandpenter=enter

# kills any current keyer process to halt transmission
escape() {
  debug "${FUNCNAME[0]}"
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
  debug "${FUNCNAME[0]}"
  local callbuff=$(echo "$buff" | tr " " "$delimeter")
  if [[ $(grep -i "$callbuff" "$callfile" | wc -l)  -eq 1 ]]
  then
    local buffexchange=$(grep -i "^$callbuff" "$callfile" | cut -d"$delimeter" -f2- | tr "$delimeter" ' ')
    echo "grep -i \"$callbuff\" \"$callfile\" | cut -d\"$delimeter\" -f1)" >> debug
    local call=$(grep -i "$callbuff" "$callfile" | cut -d"$delimeter" -f1)
    buff="$call $buffexchange"
    subbuff=""
    echo "single: $callbuff" >> debug
    drawbuff
    drawsubmenu
  else
    subbuff=$(grep -i "^$callbuff" "$callfile" | cut -d"$delimeter" -f1 | tr '\r\n' ' ')
    echo "mult: $callbuff" >> debug
    drawsubmenu
  fi
}
runtab=tab
sandptab=tab

# appends a space to the buffer
space() {
  debug "${FUNCNAME[0]}"
  appendbuff " "
}
runspace=space
sandpspace=space

# remove a char from the buffer
backspace() {
  debug "${FUNCNAME[0]}"
  if [[ ! -z "$buff" ]]
  then
    buff="${buff:0:-1}"
    if [[ "${#buff}" -ge "3" ]]
    then
      local call=$(echo "$buff" | cut -d' ' -f1)
      dupe=$(checkdupe "$call")
    else
      dupe="false"
    fi

    if [[ "$dupe" == "true" ]]
    then
      tput setaf 1
    fi

    tput el1
    tput cup $buffline 0
    echo -n ">$buff"
    tput sgr0
  fi
}
runback="backspace"
sandpback="backspace"

#
# ------------ drawing routines ---------------
#

# draw the main menu screen and calculate buffline
menu() {
  debug "${FUNCNAME[0]}"
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
  debug "${FUNCNAME[0]}"
  tput cup $1 0
  tput el
}

drawlastaction() {
  debug "${FUNCNAME[0]}"
  tput sc
  clearline $lastactionline
  tput dim
  echo "Last action: $lastaction"
  tput sgr0
  tput rc
}

# takes a single argument of the text to append to buff
appendbuff() {
  debug "${FUNCNAME[0]}"
  buff="$buff$1"
  tput el1

  if [[ "${#buff}" -ge "3" ]]
  then
    local call=$(echo "$buff" | cut -d' ' -f1)
    dupe=$(checkdupe "$call")
  fi

  if [[ "$dupe" == "true" ]]
  then
    tput setaf 1
  fi
  tput cup $buffline 0
  echo -n ">$buff"
  tput sgr0
}

clearbuff() {
  debug "${FUNCNAME[0]}"
  buff=""
  drawbuff
}

clearscreen() {
  debug "${FUNCNAME[0]}"
  tput clear
}

drawbuff() {
  debug "${FUNCNAME[0]}"
  clearline $buffline
  tput cup $buffline 0
  echo -n ">$buff"
  tput sgr0
}

drawstatus() {
  debug "${FUNCNAME[0]}"
  status="Mode: $logmode  Speed: $speed Freq: $freq Call: $mycall QSO: $qsocount"
  tput sc
  clearline $statusline
  tput bold
  echo "$status"
  tput sgr0
  tput rc
}

drawsubmenu() {
  debug "${FUNCNAME[0]}"
  tput sc
  let subline=$buffline+2
  tput cup $subline 0
  tput ed
  echo $subbuff
  tput rc
}

#
# ------------ main loop and script init ---------------
#

mainloop() {
  debug "${FUNCNAME[0]}"
  debug "my pid $BASHPID"
  if [ ! -f "$logfile" ]; then
    touch "$logfile"
  fi
  getfreq
  buff=""
  subbuff=""
  lastaction=""
  dupe="false"
  statusline=0
  lastactionline=1
  menuline=2
  qsocount=0
  serial=1
  cqpid=""
  menu
  while true
  do
    key=$(readkey)
    mappedkey=$(mapkey "$key")
    killcqpid
    execfunc "$mappedkey" "$logmode"
  done
}

# we MUST initialize our keycodes
initkeys
# call our main loop
mainloop
