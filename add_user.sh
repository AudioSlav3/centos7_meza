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
  echo -e "${err}Please run as user with sudo privelege${NC}"
  exit 1
fi
##### CHECK for parameter 
if [ $# -ne 2 ]; then
  echo -e "${err}Missing user information. Use:"
  echo -e "      add_user.sh ${purple}user${NC} (${purple}cadre${NC}|${purple}pd${NC}|${purple}gen_ndc${NC}|${purple}admin${NC}) ${NC}"
  exit 2
fi

add_admin () {
   usr=$1
   wiki=$2
   echo -e "${update}Adding${cyan} ${usr} ${NC}as admin to ${cyan}${wiki}${NC}"
   case $wiki in 
     demo)
	   sudo WIKI=${wiki} php /opt/htdocs/mediawiki/maintenance/createAndPromote.php --force --bureaucrat --sysop --custom-groups=Viewer $usr $default_pswd
	   ;;
     poic)
       sudo WIKI=${wiki} php /opt/htdocs/mediawiki/maintenance/createAndPromote.php --force --bureaucrat --sysop --custom-groups=ndc,cadre,pd $usr $default_pswd
	   ;;
   esac
}

add_contributer () {
   usr=$1
   wiki=$2
   custom_groups=$3
   echo -e "${update}Adding${cyan} ${usr} ${NC}as contributor to ${cyan}${t}${NC}"
   case $t in 
	   demo)
	     sudo WIKI=${t} php /opt/htdocs/mediawiki/maintenance/createAndPromote.php --force --custom-groups=Viewer $usr $default_pswd
	   ;;
	   poic)
	     sudo WIKI=${t} php /opt/htdocs/mediawiki/maintenance/createAndPromote.php --force --custom-groups=ndc $usr $default_pswd
	   ;;
	   # science)
	     # sudo WIKI=${t} php /opt/htdocs/mediawiki/maintenance/createAndPromote.php --force --custom-groups=project $usr $default_pswd
	   # ;;
	   # cadre)
	     # sudo WIKI=${t} php /opt/htdocs/mediawiki/maintenance/createAndPromote.php --force --custom-groups=cadre $usr $default_pswd
	   # ;;
	   *)
	     echo "${t} not defined"
	   ;;
   esac

}

default_pswd=$(date +%s | sha256sum | base64 | head -c 14 ; echo)
wikis=()
wikis=$(ls /opt/conf-meza/public/wikis/)
for t in ${wikis[*]}; do 
 case $2 in 
  cadre)
    add_contributer $1 $t cadre
	;;
  gen_ndc)
    add_contributer $1 $t ndc
	;;
  pd)
    add_contributer $1 $t pd
	;;
  admin)
    add_admin $1 $t
	;;
  *)
      echo -e "${err}Missing user information. Use:"
	  echo -e "      add_user.sh ${purple}user${NC} (${purple}cadre${NC}|${purple}pd${NC}|${purple}gen_ndc${NC}|${purple}admin${NC}) ${NC}"
	  exit 2
	;;
 esac
done
echo -e "${info}${cyan}${usr}${NC}'s default password is${cyan} ${default_pswd} ${NC}"