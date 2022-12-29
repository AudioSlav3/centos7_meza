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

start_menu () {
  donewithusers=1
  while ! $donewithusers; do 
    dialog --inputbox "Enter username to add:" 10 40 2>dialog.wiki_user
    wiki_user=$(cat dialog.wiki_user)
    rm dialog.wiki_user
    dialog --title "User Password Option" --yesno "Would you like to set the password for the user?" 10 40
    wiki_pwd_opt=$?
    if [ $wiki_pwd_opt = 0 ]; then 
      dialog --inputbox "Enter password for $wiki_user:" 10 40 2>dialog.wiki_pwd
      wiki_pwd=$(cat dialog.wiki_pwd)
	  rm dialog.wiki_pwd
    fi
    dialog --title "Account Type" --radiolist "Which account type is $wiki_user ?" 10 40 10 1 admin OFF 2 cadre OFF 3 pd OFF 4 other ON 2>dialog.wiki_account
    wiki_account=$(cat dialog.wiki_account)
    rm dialog.wiki_account
    
	dialog --infobox "Adding User $wiki_user as $wiki_account" 10 40
	dialog --yesno "Would you like to add another user?" 10 40
    if [ $? = 1 ]; then
	  donewithusers=0
	fi
  done
  clear
  echo $wiki_user $wiki_pwd_opt $wiki_pwd $wiki_account
}

# chk_param () {
#### CHECK for parameter 
# username=null
# password=null
# account=null
# wiki_db_usr=null
# wiki_db_pwd=null
# sql_db_info=1
# while getopts u:p:a:wu:wp: flag
# do
  # case "${flag}" in
    # u) username=${OPTARG};;
    # p) password=${OPTARG};;
	# a) account=${OPTARG};;
    # wu) wiki_db_usr=${OPTARG};;
	# wp) wiki_db_pwd=${OPTARG};;
  # esac
# done
# if [ $username = null ] && [ $account = null ]; then
  # echo -e "${err}Missing user information. Use:"
  # echo -e "      add_user.sh -u ${purple}user${NC} [-p ${purple}password${NC}] -a (${purple}admin${NC}|${purple}cadre${NC}|${purple}pd${NC}|${purple}other${NC}) [-wu ${purple}wiki_db_user${NC} -wu ${purple}wiki_db_password${NC}]${NC}"
  # exit 2
# fi
# if [ ! $wiki_db_usr = null ] && [ ! $wiki_db_pwd = null ]; then 
  # sql_db_info=0
# fi
# }
# add_admin () {
   # usr=$1
   # wiki=$2
   # echo -e "${update}Adding${cyan} ${usr} ${NC}as admin to ${cyan}${wiki}${NC}"
   # case $wiki in 
     # demo)
	   # sudo WIKI=${wiki} php /opt/htdocs/mediawiki/maintenance/createAndPromote.php --force --bureaucrat --sysop --custom-groups=Viewer $usr $default_pswd
	   # ;;
     # poic)
       # sudo WIKI=${wiki} php /opt/htdocs/mediawiki/maintenance/createAndPromote.php --force --bureaucrat --sysop --custom-groups=ndc,cadre,pd $usr $default_pswd
	   # ;;
   # esac
# }

# add_contributer () {
   # usr=$1
   # wiki=$2
   # custom_groups=$3
   # echo -e "${update}Adding${cyan} ${usr} ${NC}as contributor to ${cyan}${t}${NC}"
   # case $t in 
	   # demo)
	     # sudo WIKI=${t} php /opt/htdocs/mediawiki/maintenance/createAndPromote.php --force --custom-groups=Viewer $usr $default_pswd
	   # ;;
	   # poic)
	     # sudo WIKI=${t} php /opt/htdocs/mediawiki/maintenance/createAndPromote.php --force --custom-groups=$custom_groups $usr $default_pswd
	   # ;;
	   ##science)
	   ##  sudo WIKI=${t} php /opt/htdocs/mediawiki/maintenance/createAndPromote.php --force --custom-groups=project $usr $default_pswd
	   ##;;
	   ##cadre)
	   ##  sudo WIKI=${t} php /opt/htdocs/mediawiki/maintenance/createAndPromote.php --force --custom-groups=cadre $usr $default_pswd
	   ##;;
	   # *)
	     # echo "${t} not defined"
	   # ;;
   # esac

# }

# check for user () {
##$1 = username
##$2 = db user - default 'wiki_app_user'
##$3 = db pass - default 'DummyPasw0rd$'
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

# old_style () {
# default_pswd=$(date +%s | sha256sum | base64 | head -c 14 ; echo)
# wikis=()
# wikis=$(ls /opt/conf-meza/public/wikis/)
# for t in ${wikis[*]}; do 
 # case $2 in 
  # cadre)
    # add_contributer $1 $t cadre
	# ;;
  # gen_ndc)
    # add_contributer $1 $t ndc
	# ;;
  # pd)
    # add_contributer $1 $t pd
	# ;;
  # admin)
    # add_admin $1 $t
	# ;;
  # *)
      # echo -e "${err}Missing user information. Use:"
	  # echo -e "      add_user.sh ${purple}user${NC} (${purple}cadre${NC}|${purple}pd${NC}|${purple}gen_ndc${NC}|${purple}admin${NC}) ${NC}"
	  # exit 2
	# ;;
 # esac
# done
# echo -e "${info}${cyan}${usr}${NC}'s default password is${cyan} ${default_pswd} ${NC}"
# }

start_menu