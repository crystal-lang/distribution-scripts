START_STEP=${START_STEP:-1}
step_number=1

step(){
  message="$1"
  shift
  command="$*"

  echo
  echo -e "\033[33m===============================================================================\033[0m"
  echo -e "\033[33m$step_number. $message\033[0m"
  echo
  echo -en "$ $command"
  step_number=$(expr $step_number + 1)
  if [ $step_number -lt $START_STEP ]; then
    echo -e " \033[33m(skipped)\033[0m"
    return
  fi

  read -r REPLY

  if [ "$REPLY" != "skip" ]; then
    eval "$command"
  else
    echo -e "\033[33m(skipped)\033[0m"
  fi
}
