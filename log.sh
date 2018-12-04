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

runmenu() {
#  tput clear
  echo "runmenu"
  echo -e ">$buff"
}
sandpmenu() {
  tput clear
  echo "sandpmenu"
  echo -e ">$buff"
}

# this expects the function name as arg1, and the logmode as arg2
exec_func() {
  # create a named function based on the key and mode
  func="$2$1"
  if [ -n "$(type -t $func)" ] && [ "$(type -t $func)" = function ]
  then
    $func
  else
    appendbuff "$1"
  fi
}

runf1() {
  echo "run f1"
}

runf2() {
  echo "run f2"
}

runf3() {
  echo "run f3"
}

runf4() {
  echo "run f4"
}

runf5() {
  echo "run f5"
}

runf6() {
  echo "run f6"
}

runf7() {
  echo "run f7"
}

runf8() {
  echo "run f8"
}

runf9() {
  echo "run f9"
}

runenter() {
  echo "run enter"
}

sandpf1() {
  echo "sandp f1"
}

sandpf2() {
  echo "sandp f2"
}

sandpf3() {
  echo "sandp f3"
}

sandpf4() {
  echo "sandp f4"
}

sandpf5() {
  echo "sandp f5"
}

sandpf6() {
  echo "sandp f6"
}

sandpf7() {
  echo "sandp f7"
}

sandpf8() {
  echo "sandp f8"
}

sandpf9() {
  echo "sandp f9"
}

sandpenter() {
  echo "sandp enter"
}


backspace() {
  buff="${buff:0:-1}"
}

# takes a single argument of the text to append to buff
appendbuff() {
  buff="$buff$1"
}

mainloop() {
  buff=""
  while true
  do
    if [[ "$logmode" == "run" ]]
    then
      runmenu
    else
      sandpmenu
    fi
    key=$(readkey)
    mappedkey=$(mapkey "$key")
    echo "$mappedkey"
    exec_func $mappedkey $logmode
  done
}

# we MUST initialize our keycodes
initkeys
# call our main loop
mainloop
