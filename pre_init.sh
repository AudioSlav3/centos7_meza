#!/bin/bash

#Colors
red="\033[00;31m"
RED="\033[01;31m"
green="\033[00;32m"
GREEN="\033[01;32m"
brown="\033[00;33m"
YELLOW="\033[01;33m"
blue="\033[00;34m"
BLUE="\033[01;34m"
purple="\033[00;35m"
PURPLE="\033[01;35m"
cyan="\033[00;36m"
CYAN="\033[01;36m"
white="\033[00;37m"
WHITE="\033[01;37m"
NC="\033[00m"

#
#${BLUE} -- 
info="[${BLUE}INFO${NC}] "
update="[${CYAN}UPDT${NC}] "
ok="[${GREEN} OK ${NC}] "
err="[${RED}ERR ${NC}] "
warn="[${YELLOW}WARN${NC}] "
#

##### CHECK IF USER IS ROOT 
if [ "$EUID" -ne 0 ]; then 
  echo -e "${err}Please run as root"
  exit 1
fi
adminuser=null

#################################
##### Add user to sudoers
update_sudo () {
 if test -f "${HOME}/sudo.done"; then
   echo -e "${ok}Nothing to do."
   	echo -e "${cyan} If not already done, run pre_init2.sh as user with sudo priveledges."
 fi
 while ! test -f "${HOME}/sudo.done"; do 
  sudouser=()
  sudousers=$(cut -d: -f1 /etc/passwd | egrep -v "bin|daemon|adm|lp|sync|shutdown|halt|mail|operator|games|ftp|nobody|systemd-network|dbus|polkitd|sshd|postfix|root"|xargs)
  for t in $sudousers; do 
    sudouser+=( ${t} )
  done
  if [ ${#sudouser[@]} -ne 1 ]; then
    echo echo -e "${err}Either too many users or insufficent users found.${NC}"
	echo -e "${CYAN}Users found:${NC}"
    printf "%s\n" "${sudouser[@]}"
    echo -e "${info}#### PERFORM THE FOLLOWING AS ROOT ###${NC}"
    echo -e "${info}## sudo visudo ${NC}"
    echo -e "${info}## Add to end of file:${NC}"
    echo -e "${info}## ${purple}${USER}  ALL=(ALL)       NOPASSWD: ALL${NC}"
    echo -e "${info}## :wq${NC}"
    echo -e "${info}######################################${NC}"
    echo -e "${brown} Press [ENTER] ONLY AFTER completing ALL of the above.${NC}" 
    read ans
    sudo visudo
    read ans
  else 
    adminuser=${sudouser[0]}
    echo "${sudouser[0]} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/${adminuser}
    chown root:root /etc/sudoers.d/${adminuser}
  fi
  if $(cat /etc/sudoers | grep -q ${adminuser}) || test -f "/etc/sudoers.d/${adminuser}" ; then
    touch ${HOME}/sudo.done
  fi

   if $(sudo -l -U ${adminuser}|grep -q "(ALL) NOPASSWD: ALL"); then
    echo -e "${ok}Successfully added ${adminuser} to sudoers"
	echo -e "${cyan} Run pre_init2.sh as ${adminuser}"
   fi
 done
}
update_sudo