#!/bin/bash
#
#Functions used in zipcode_lookup_cowles.sh
#

#convert argument to upper case
function selection_2_UC() {
  echo $1 | tr '[:lower:]' '[:upper:]'
}
#convert argument to have first character upper case and the rest lower case
function initcap() {
  #convert first word
  echo -n $1 | awk '{print toupper(substr($1,1,1)) tolower(substr($1,2))}'
  #convert second word
  if [ "$2" != DC ]; then
    echo -n $2 | awk '{print toupper(substr($1,1,1)) tolower(substr($1,2))}'
  else
    echo -n $2
  fi
}
#Check if argument passed is one of the keys
#This function is not very smart as any vowel would pass
function test_exists(){
  #echo $(echo "${!State[@]}"| grep -c $1);
  foundit=0
  for state in ${!State[@]}; do
    if [ ${state} == ${1} ]; then
      foundit=1
    fi
  done
  echo $foundit
}
