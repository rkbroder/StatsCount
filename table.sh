#!/bin/bash

qMgr="$1"
typeset -A metrics # Declare an associative array
oldStart=""

echo "Waiting for input ..."

#The output from the jq script looks something like: 
#   [12345678,SYSTEM.DEFAULT.LOCAL.QUEUE,1.23]
# so we need to do some conversions to extract the fields.
while read line
do
  line2=`echo $line | sed "s/\[//g;s/]//g;s/\"//g"`
  # Make sure the variables are set here - in bash, pipes are subshells so 
  # can't set variables in the main function. Meaning "echo 1 2 3 | read x y z" doesn't
  # work as hoped. The <() syntax does what we need though.
  IFS="," read start queue rate < <(echo "$line2")

  # If we start reading a new set of metrics then display the
  # previous set and clear out the array. There's no easy "read a batch of queues"
  # from the JSON or event message output, so we use the timestamp as the discriminator.
  if [ "$start" != "$oldStart" ]
  then
    # Is the array empty?
    len=${#metrics[@]}
    if [ $len != 0 ]
    then
      tput clear
      echo "Metrics collected for $qMgr at `date`"
      echo 
      printf "%-48.48s %s\n" "Queue" "Puts/Sec"
      printf "%-48.48s %s\n" "-----" "--------"

      # Find all the queue names and sort them ready for printing
      for key in "${!metrics[@]}"
      do
        echo $key
      done | sort |\
      while read queue
      do
        printf "%-48.48s %.2f\n" $queue ${metrics["$queue"]}
      done
   
      # Empty the array for next time round - can't do it inside the "while" loop
      for key in "${!metrics[@]}"
      do
        unset metrics["$key"]
      done  

      echo "--------------"
    fi
    oldStart=$start
  else
    metrics["$queue"]=$rate
  fi
done    
