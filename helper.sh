#!/bin/bash

Yellow='\033[1;33m'
Red='\033[0;31m'
Green='\033[0;32m'
NC='\033[0m'
Orange='\033[0;33m'

auditor () {
  terminal_sets=$(stty -g)
  data=$(nmap -Pn --script ssl-enum-ciphers -p 443 $1 | awk '{print $2}' | grep "TLS" | sed 's/://g')
  if [[ -z $data ]];then
    :
  else
    echo -e $Orange"Powered By: BERGHEM - Smart Information Security"$NC
    for ciphers in $data
    do
      echo $ciphers >> .out
    done
    cat .out | sed -n '/^TLSv/{h;n}; /^TLS_/{G;s/\n/-/p}' >> .ready-to-go
    for ciphers in $(cat .ready-to-go)
    do
      cipher=$(echo $ciphers | awk -F "-" '{print $1}')
      if [[ $cipher == *"AKE"* ]];then
        cipher=$(echo $cipher | sed 's/_AKE_WITH//g')
      else
        :
      fi
      version=$(echo $ciphers | awk -F "-" '{print $2}' | sed 's/ //g')
      ciphersuite="[*] Requesting CipherSuite for ["$Red"https://"$1$NC"]"
      printf "\r$ciphersuite"
      response=$(curl -s https://ciphersuite.info/cs/$cipher/)
      result1=$(echo $response | sed 's/>/\n/g' | sed 's/</\n/g' | grep "a href" | sed 's/"//g' | grep $cipher | awk -F "/" '{print $4}')
      result2=$(echo $response | sed 's/> /\n/g' | grep "bg-danger\|bg-success\|bg-secure\|bg-warning" | cut -d '>' -f 2 | cut -d '<' -f 1)
      if [[ -z "$result1" ]];then
      not="!Not Found!"
      info="MANUAL SEARCH REQUIRED"
      echo -e $Red$not$NC"-"$Red$cipher$NC"-"$Red$info$NC >> .not-found.txt
      elif [[ "Weak" == *"$result2"*  ]];then
      colorful_weak2="[$Yellow$result2$NC]"
      colorful_weak1="[$Yellow$result1$NC]"
      version_of_version="[$version]"
      echo -e $colorful_weak2"-"$colorful_weak1"-"$version_of_version >> .weak-ones.txt
      elif [[ "Insecure" == *"$result2"* ]];then
      colorful_insecure2="[$Red$result2$NC]"
      colorful_insecure1="[$Red$result1$NC]"
      version_of_version="[$version]"
      echo -e $colorful_insecure2"-"$colorful_insecure1"-"$version_of_version >> .insecure-ones.txt
      else
      colorful_strong2="[$Green$result2$NC]"
      colorful_strong1="[$Green$result1$NC]"
      version_of_version="[$version]"
      echo -e $colorful_strong2"-"$colorful_strong1"-"$version_of_version >> .secure-ones.txt
      fi
    done
    tput cnorm
    stty "$terminal_sets"
    echo
    secure_results=$(file .secure-ones.txt | awk -F ": " '{print $2}')
    weak_results=$(file .weak-ones.txt | awk -F ": " '{print $2}')
    insecure_results=$(file .insecure-ones.txt | awk -F ": " '{print $2}')
    not_results=$(file .not-found.txt | awk -F ": " '{print $2}')

    hold="[*] Sorting output. Please Wait!"
    echo $hold
#    dis_ok="\033[30m####\033[m"
#    dis_dan="\033[31m####\033[m"
#    good="\033[34m####\033[m"
#    status=$(cat .*.txt | awk -F "-" '{print $3}' | sort -u)
#    for c in "TLSv1.0" "TLSv1.1" "TLSv1.2" "TLSv1.3";do
#      if [[ $status == *"$c"* ]];then
#        if [[ 
#      else
#        echo "$c disabled"
#      fi
#    done
    if [[ "$secure_results" == *"empty"* ]];then
    :
    elif [[ "$secure_results" == *"cannot open"* ]];then
    :
    else
    for x in $(cat .secure-ones.txt | awk '{print length " ?"$N0}' | sort -rn | cut -d '?' -f 2);do echo $x && sleep 0.2;done
    rm .secure-ones.txt
    fi

    if [[ "$weak_results" == *"empty"* ]];then
    :
    elif [[ "$weak_results" == *"cannot open"* ]];then
    :
    else
    for x in $(cat .weak-ones.txt | awk '{print length " ?"$N0}' | sort -rn | cut -d '?' -f 2);do echo $x && sleep 0.2;done
    rm .weak-ones.txt
    fi

    if [[ "$insecure_results" == *"empty"* ]];then
    :
    elif [[ "$insecure_results" == *"cannot open"* ]];then
    :
    else
    for x in $(cat .insecure-ones.txt | awk '{print length " ?"$N0}' | sort -rn | cut -d '?' -f 2);do echo $x && sleep 0.2;done
    rm .insecure-ones.txt
    fi

    if [[ "$not_results" == *"empty"* ]];then
    :
    elif [[ "$not_results" == *"cannot open"* ]];then
    :
    else
    for x in $(cat .not-found.txt | awk '{print length " ?"$N0}' | sort -rn | cut -d '?' -f 2);do echo $x && sleep 0.2;done
    rm .not-found.txt
    fi
    rm .out .ready-to-go
    #for x in $(cat *.txt)
    echo ""
  fi
}
