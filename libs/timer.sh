#!/bin/bash
touch second.txt
i=0
while true
do
   echo "$i" > second.txt
   i=$(( $i + 1 ))
   sleep 1
done
