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
if [ "$EUID" -eq 0 ]; then 
  echo -e "${err}Please run as user with sudo privelege"
  exit 1
fi

add_admin () {
 echo .
}

add_contributer () {
   usr=$1
   default_pswd=tmp_pswd=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-12};echo)
   wikis=()
   wikis=$(ls /opt/conf-meza/public/wikis/ | grep -v demo)
   for t in ${wikis[*]}; do 
     echo -e "${update}Creating ${usr} to ${t}${NC}"
     #WIKI=${t} php /opt/htdocs/mediawiki/maintenance/createAndPromote.php --force --bureaucrat --sysop --custom-groups=Contributor $usr $default_pswd
   done
   echo -e "${info}$usr default password is ' $default_pswd '${NC}"
}
add_contributer $1