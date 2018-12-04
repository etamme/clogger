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
    *) echo "$1";;
  esac
}

menu() {
  lines=0
  tput clear
  tput bold
  echo "Mode: $logmode"
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
  # create a named function based on the key and mode
  func="$2$1"
  if [ -n "$(type -t ${!func})" ] && [ "$(type -t ${!func})" = function ]
  then
# TODO work on supporting chained functions via array definition
#    if [[ "$(declare -p $func)" =~ "declare -a" ]]; then
#      status="array"
#    else
      ${!func}
#    fi
  else
    appendbuff "$1"
  fi
}

# takes speed and text to send as arguments
cwsend() {
 status "sending cw"
}

# these are the defined functions that you can map f1-f9 to for each mode
sendbuff() {
 status="$buff"
 menu
}

sendcq() {
 status="$mycq"
 menu
}

sendexchange() {
 status="$myexchange"
 menu
}

sendmycall() {
 status="$mycall"
 menu
}
sendtu() {
  status="TU"
 menu
}
sendagn() {
 status="$myagn"
 menu
}
logqso() {
  status="QSO logged"
 menu
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
  echo "run enter"
}

sandpenter() {
  echo "sandp enter"
}

runback="backspace"
sandpback="backspace"

backspace() {
  buff="${buff:0:-1}"
  tput el1
  tput cup $lines 0
  echo -n ">$buff"
}

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
    execfunc $mappedkey $logmode
  done
}

# we MUST initialize our keycodes
initkeys
# call our main loop
mainloop
