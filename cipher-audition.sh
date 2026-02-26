#!/bin/bash

Orange='\033[0;33m'
Yellow='\033[1;33m'
Red='\033[0;31m'
Green='\033[0;32m'
NC='\033[0m'

evall=$(file $1)
source helper.sh


if [[ "$evall" ==  *"No such file or directory"* ]];then
  dots=$(echo $1 | grep -o "\." | wc -l)
  if [[ $1 == http* ]];then
      echo "[!]-Strip out the protocol \`http(s)://\`"
  else
    if [[ $dots -gt 1 ]];then
      auditor $1
    elif [[ $dots -eq 1 && $1 == *.com || $dots -eq 1 && $1 == *com.br ]];then
      auditor $1
    else
      echo "[!]-That's not a valid target"
    fi
  fi
elif [[ "$evall == "*"ASCII"* ]];then
  for x in $(cat $1);do
    if [[ $x == http* ]];then
      x=$(echo $x | awk -F '//' '{print $2}')
      if [[ $x == */ ]];then
        x=$(echo $x | sed 's/.$//g')
        auditor $x
      else
        auditor $x
      fi
    elif [[ $x != http* ]];then
      if [[ $x == */ ]];then
        x=$(echo $x | sed 's/.$//g')
        auditor $x
      else
        auditor $x
      fi
    fi
  done
else
  echo "[!]-Not implemented yet!"
fi
