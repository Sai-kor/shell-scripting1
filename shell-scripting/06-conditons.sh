#!/bin/bash
read -r -p "Enter your age:" age
if [ -z "${age}" ]; then
echo Input missing
exit
fi
if [ ! -z "${age}" -a "${age}" -lt 18 ]; then
  echo "you are minor"
elif [ "${age}" -gt 60 ]; then
  echo you are a senior citizen
else
  echo you are major
fi