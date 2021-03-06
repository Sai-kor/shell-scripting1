#!/bin/bash
USER_UID=$(id -u)
if [ "${USER_UID}" -ne 0 ]; then
echo -e "\e[1;31mYou should be a root user to perform this script\e[0m"
exit
fi

export component=$1
if [ -z "${component}" ]; then
  echo -e "\e[1;31mcomponent input missing\e[0m"
  exit
fi
if [ ! -e Components/"${component}".sh ]; then
  echo -e "\e[1;31mgiven component script does not exist\e[0m"
  exit
fi

bash Components/"${component}".sh