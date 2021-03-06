#!/bin/bash

function get_salt {
  SALTLENGTH=64
  salts=$(
    strings </dev/urandom | while read line; do
            echo $line | tr '\n\t ' $RANDOM:0:1 >> /tmp/.salt.$$
            salt=$(cat /tmp/.salt.$$)
            if [ ${#salt} -ge $SALTLENGTH ]; then
              salt=${salt:0:$SALTLENGTH}
              echo $salt
              break
            fi
    done)
  rm -f /tmp/.salt.$$
}

while [ $(grep -i -c "generateme" .env) -gt 0 ]; do
  get_salt
  if [[ $salts == *'&'* ]]; then
    continue
  fi
  if [[ $salts == *'\'* ]]; then
    continue
  fi
  awk -v s=$salts 'NR==1,/generateme/{sub(/generateme/, s)} 1' .env > .env.temp
  mv .env.temp .env
done

echo "Salts Generated"
