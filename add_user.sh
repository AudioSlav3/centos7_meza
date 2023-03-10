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


add_admin () {
   usr=$1
   wiki=$2
   echo -e "${update}Adding${cyan} ${usr} ${NC}as admin to ${cyan}${wiki}${NC}"
   case $wiki in 
     demo)
	   sudo WIKI=${wiki} php /opt/htdocs/mediawiki/maintenance/createAndPromote.php --force --bureaucrat --sysop --custom-groups=Viewer $usr ${wiki_pwd}
	   ;;
     poic)
       sudo WIKI=${wiki} php /opt/htdocs/mediawiki/maintenance/createAndPromote.php --force --bureaucrat --sysop --custom-groups=ndc,cadre,pd $usr ${wiki_pwd}
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
	     sudo WIKI=${t} php /opt/htdocs/mediawiki/maintenance/createAndPromote.php --force --custom-groups=Viewer $usr ${wiki_pwd}
	   ;;
	   poic)
	     sudo WIKI=${t} php /opt/htdocs/mediawiki/maintenance/createAndPromote.php --force --custom-groups=$custom_groups $usr ${wiki_pwd}
	   ;;
	   *)
	     echo "${t} not defined"
	   ;;
   esac

}

# check for user () {
##$1 = wikiuser
##$2 = db user - default 'wiki_app_user'
##$3 = db pass 
##$4 = database - demo vs poic 
# RESULT_VARIABLE=$(mysql -u$2 -p$3 wiki_$4 -sse "SELECT EXISTS(SELECT 1 FROM user WHERE user_name = '${1^}')")

# if [ "$RESULT_VARIABLE" = 1 ]; then
  ## True
  # return 0
# else
  ## False
  # return 1
# fi
# }

start_menu () {
  donewithusers=1
  wikis=()
  wikis=$(ls /opt/conf-meza/public/wikis/)
  while [ ! $donewithusers = 0 ]; do 
    dialog --inputbox "Enter username to add:" 10 40 2>dialog.wiki_user
    wiki_user=$(cat dialog.wiki_user)
    rm dialog.wiki_user
    dialog --title "User Password Option" --yesno "Would you like to set the password for the user?" 10 40
    wiki_pwd_opt=$?
    if [ $wiki_pwd_opt = 0 ]; then 
      dialog --inputbox "Enter password for $wiki_user:" 10 40 2>dialog.wiki_pwd
      wiki_pwd=$(cat dialog.wiki_pwd)
	  rm dialog.wiki_pwd
	else
	  wiki_pwd=$(date +%s | sha256sum | base64 | head -c 14 ; echo)
    fi
    dialog --no-items --title "Account Type" --radiolist "Which account type is $wiki_user ?" 20 40 6 admin OFF cadre OFF pd OFF other ON 2>dialog.wiki_account
    wiki_account=$(cat dialog.wiki_account)
    rm dialog.wiki_account
    clear
	for t in ${wikis[*]}; do 
	  case ${wiki_account} in 
		cadre)
			add_contributer ${wiki_user} $t cadre
			;;
		other)
		    #also known as generic NDC account
			add_contributer ${wiki_user} $t ndc
			;;
		pd)
			add_contributer ${wiki_user} $t pd
			;;
		admin)
			add_admin ${wiki_user} $t
			;;
	  esac
	done
	read -p "Press any key to continue"
	
	dialog --colors --begin 1 5 --msgbox "[ \Z4INFO\Zn ]: \Z4${wiki_user}\Zn has been added as \Z4${wiki_account}\Zn and has password set to\Z4 ${wiki_pwd} \Zn" 20 40
	
	dialog --yesno "Would you like to add another user?" 10 40
    if [ $? = 1 ]; then
	  donewithusers=0
	fi
  done
  clear
}
start_menu