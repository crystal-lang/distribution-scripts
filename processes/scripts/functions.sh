#!/bin/sh
START_STEP=${START_STEP:-${1:-1}}
step_number=1

step(){
  message="$1"
  shift
  command="$*"

  echo
  printf "\033[33m===============================================================================\033[0m\n"
  printf "\033[33m%2d. %s\033[0m\n" "$step_number" "$message"
  echo
  printf "$ %s" "$command"
  step_number=$((step_number + 1))
  if [ "$step_number" -lt "$START_STEP" ]; then
    printf " \033[33m(skipped)\033[0m\n"
    return
  fi

  read -r REPLY

  if [ "$REPLY" != "skip" ]; then
    eval "$command"
  else
    printf "\033[33m(skipped)\033[0m\n"
  fi
}
