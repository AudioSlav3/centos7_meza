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

#
# Config File Variables
variable_dirs="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)/public_meza"
config_file_dirs="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)/config_public"
delta_config_file_dirs="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)/delta_config_public"
##wiki_list=(poic science cadre)
wiki_list=(demo poic)
status=null
# Function to compare hashes
check_hash () {
  source_file=$1
  dest_file=$2
  source_hash=$(sha1sum $source_file | cut -d " " -f 1|xargs)
  dest_hash=$(sha1sum $dest_file | cut -d " " -f 1|xargs)
  if "$source_hash" = "$dest_hash"; then 
    return 0
  else
    return 1
  fi
}
update_meza_config () {
  sudo meza deploy monolith --tags mediawiki --skip-tags latest,update.php,verify-wiki,smw-data,search-index,parsoid,mediawiki-core
  status=$?
}
update_meza_ext () {
  sudo meza deploy monolith --tags mediawiki --skip-tags mediawiki-core,verify-wiki
  status=$?
}

#################################
##### BASE MEZA Install
install_meza_base () {
 if test -f "${HOME}/meza_base.done"; then
   echo -e "${ok}MEZA Wiki already installed.${NC}"
 fi
  if ! test -d "/opt/meza"; then
     sudo git clone https://github.com/enterprisemediawiki/meza /opt/meza
  fi
  while ! test -f "${HOME}/meza_base.done"; do 
    echo -e "${update}Installing MEZA Wiki, this will take a while.${NC}"
    sudo bash /opt/meza/src/scripts/getmeza.sh
	sudo meza deploy monolith	
   if [[ $status -eq 0 ]]; then
	   touch ${HOME}/meza_base.done
	   echo -e "${ok}MEZA Wiki installed.${NC}"
	else 
	   echo -e "${warn}Something didn't go right, correct any issues and try again.${NC}"
	   exit 1
	fi
  done
}
#################################
##### Extension Install
install_mediawiki_extensions () {
 if test -f "${HOME}/mediawiki_extension.done"; then
   echo -e "${ok}MEZA Wiki extensions already installed.${NC}"
 fi
  while ! test -f "${HOME}/mediawiki_extension.done"; do 
    echo -e "${info}Installing MEZA Wiki extensions.${NC}"
	echo -e "${update}Copying MezaLocalExtensions.yml${NC}"
    sudo cp $config_file_dirs/MezaLocalExtensions.yml /opt/conf-meza/public/
	echo -e "${update}Installing new Extension${NC}"
	update_meza_ext	
	if [[ $status -eq 0 ]]; then
		touch ${HOME}/mediawiki_extension.done
		echo -e "${ok}Done.${NC}"
	else 
	   echo -e "${warn}Something didn't go right, correct any issues and try again.${NC}"
	   exit 1
	fi
  done
}

#################################
##### START Write public files
meza_public_init () {
 if test -f "${HOME}/meza_config_init.done"; then
   echo -e "${ok}Initial custom public.yml already in place.${NC}"
 fi
 while ! test -f "${HOME}/meza_config_init.done"; do 
   echo -e "${info}Configuring MEZA Wiki settings${NC}"
   echo -e "${update}Copying public.yml${NC}"
   sudo cp -R $config_file_dirs/* /opt/conf-meza/public/
   echo -e "${update}Applying new config.${NC}"
   update_meza_config
   if [[ $status -eq 0 ]]; then
	   touch ${HOME}/meza_config_init.done
	   echo -e "${ok}Done.${NC}"
   else 
	   echo -e "${warn}Something didn't go right, correct any issues and try again.${NC}"
	   exit 1
   fi
 done
}
##### END   Write public files
#################################
##### START WIKI Deploy
add_wikis () {
 echo -e "${info}Checking for Wikis to deploy.${NC}"
 #Read File to use in deploy
 header_wikis=()
 middle_wikis=()
 footer_wikis=()
 cfg_updt=1

 for wikiid in ${wiki_list[@]}
 do
    #set demo wiki for anyone to read
	if [ "$wikiid" = "demo" ]; then 
	  echo -e "${update}Updating demo base.php to allow anyone to read Wiki, but onlly admin to write.${NC}"
	  if ! $(grep -q demo-perms /opt/conf-meza/public/wikis/demo/preLocalSettings.d/base.php); then
		  cat $variable_dirs/demo_perm.txt | sudo tee -a /opt/conf-meza/public/wikis/demo/preLocalSettings.d/base.php
		  #sudo sed -i 's/\/\/ $mezaAuthType = \x27viewer-read\x27;/$mezaAuthType = \x27anon-read\x27;/g' /opt/conf-meza/public/wikis/demo/preLocalSettings.d/base.php
	  fi
	  sudo cp $delta_config_file_dirs/wikis/demo/* /opt/conf-meza/public/wikis/demo/
	  sudo sed -i "s/Sitename = 'Demo Wiki'/Sitename = 'How To'/g" /opt/conf-meza/public/wikis/demo/preLocalSettings.d/base.php
	fi
	if ! test -d "/opt/conf-meza/public/wikis/$wikiid/"; then 
	  echo -e "${update}Deploying Wiki:${NC}"
      echo -e "${cyan}        $wikiid, $wikititle${NC}"
	  case $wikiid in 
	    poic)
		  sudo meza create wiki-promptless monolith $wikiid "HOSC Wiki"
		  echo -e "${update}Copying icon and image to Wiki${purple} $wikiid${NC}"
		  sudo cp $delta_config_file_dirs/wikis/$wikiid/* /opt/conf-meza/public/wikis/$wikiid/
	      #set poic wiki for ndc users to edit
	      echo -e "${update}Updating poic base.php to allow anyone with NDC to read Wiki.${NC}"
	      sudo sed -i 's/\/\/ $mezaAuthType = \x27viewer-read\x27;/$mezaAuthType = \x27ndc-edit\x27;/g' /opt/conf-meza/public/wikis/poic/preLocalSettings.d/base.php
		  cat $variable_dirs/HOSC_perm.txt | sudo tee -a /opt/conf-meza/public/wikis/$wikiid/preLocalSettings.d/base.php
		  cfg_updt=0
		;;
		science)
		  sudo meza create wiki-promptless monolith $wikiid "Science"
		  echo -e "${update}Copying icon and image to Wiki${purple} $wikiid${NC}"
		  sudo cp $delta_config_file_dirs/wikis/$wikiid/* /opt/conf-meza/public/wikis/$wikiid/
		  #set science wiki for PD and Cadre to edit
		  echo -e "${update}Updating science base.php to allow NDC to read and only PD and Cadre to edit Wiki.${NC}"
		  sudo sed -i 's/\/\/ $mezaAuthType = \x27viewer-read\x27;/$mezaAuthType = \x27project-edit\x27;/g' /opt/conf-meza/public/wikis/science/preLocalSettings.d/base.php
		  cat $variable_dirs/Sci_perm.txt | sudo tee -a /opt/conf-meza/public/wikis/$wikiid/preLocalSettings.d/base.php
		  cfg_updt=0
		;;
		cadre)
		  sudo meza create wiki-promptless monolith $wikiid "POIC Cadre"
		  echo -e "${update}Copying icon and image to Wiki${purple} $wikiid${NC}"
		  sudo cp $delta_config_file_dirs/wikis/$wikiid/* /opt/conf-meza/public/wikis/$wikiid/
		  #set cadre wiki for anyone to edit
		  echo -e "${update}Updating cadre base.php to allow only Cadre to read/edit Wiki.${NC}"
		  sudo sed -i 's/\/\/ $mezaAuthType = \x27viewer-read\x27;/$mezaAuthType = \x27cadre-edit\x27;/g' /opt/conf-meza/public/wikis/cadre/preLocalSettings.d/base.php
		  cat $variable_dirs/Cadre_perm.txt | sudo tee -a /opt/conf-meza/public/wikis/$wikiid/preLocalSettings.d/base.php
		  cfg_updt=0
		;;
	  esac
	else
	   echo -e "----- ${ok}$wikiid already deployed.${NC}"
	fi 
 done

 if [ "$cfg_updt" = "0" ]; then 
   echo -e "${update}Copying delta public configs for Wiki.${NC}"
   sudo rsync -av --exclude='wikis' $delta_config_file_dirs/ /opt/conf-meza/public/
   echo -e "${update}Applying config to apply new images.${NC}"
   sudo sed -i 's/primary_wiki_id: demo/primary_wiki_id: poic/g' /opt/conf-meza/public/public.yml
   update_meza_config
   if [[ $status -eq 0 ]]; then
		echo -e "${ok}Done.${NC}"
   else 
		echo -e "${warn}Something didn't go right, correct any issues and try again.${NC}"
		exit 1
   fi
 fi
}
create_admin () {
  default_pswd=$(date +%s | sha256sum | base64 | head -c 14 ; echo)
  sudo WIKI=demo php /opt/htdocs/mediawiki/maintenance/createAndPromote.php --force --bureaucrat --sysop --custom-groups=Viewer admin $default_pswd
  sudo WIKI=poic php /opt/htdocs/mediawiki/maintenance/createAndPromote.php --force --bureaucrat --sysop --custom-groups=ndc,cadre,pd admin $default_pswd
  echo -e "${info}${cyan}admin${NC}'s default password is${cyan} ${default_pswd} ${NC}"
}
  
##### END   
#################################
##### START INTERWIKI TABLE

## NOTE must do this for the prime wiki in the case below 'wiki_poic'
set_interwiki () {
  db_user=wiki_app_user
  msfc_server=wiki.msfc.nasa.gov
  echo -ne "${YELLOW}Enter password for Wiki MySQL Database${NC}: "
  read db_pass
  #using wiki.msfc.nasa.gov, change if this is different. 
  #HOSC Entries
   prefix=general
   if [ -z $(mysql -u${db_user} -p${db_pass} wiki_poic -sse "select iw_prefix FROM interwiki WHERE iw_prefix='$prefix';") ]; then 
	 echo -e "${info}Value does not exist, creating it${NC}"
   else
     echo -e "${info}Value exists, deleting it first before re-creating it${NC}"
	 mysql -u${db_user} -p${db_pass} wiki_poic -e "DELETE FROM interwiki WHERE iw_prefix='$prefix';" 
   fi
   mysql -u${db_user} -p${db_pass} wiki_poic -sse "INSERT INTO interwiki (iw_prefix, iw_url, iw_local, iw_trans) VALUES ('$prefix', 'https://${msfc_server}/index.php/\$1', 1, 0);"

   prefix=howto
   if [ -z $(mysql -u${db_user} -p${db_pass} wiki_poic -sse "select iw_prefix FROM interwiki WHERE iw_prefix='$prefix';") ]; then 
	 echo -e "${info}Value does not exist, creating it${NC}"
   else
     echo -e "${info}Value exists, deleting it first before re-creating it${NC}"
	 mysql -u${db_user} -p${db_pass} wiki_poic -e "DELETE FROM interwiki WHERE iw_prefix='$prefix';" 
   fi   
  mysql -u${db_user} -p${db_pass} wiki_poic -sse "INSERT INTO interwiki (iw_prefix, iw_url, iw_local, iw_trans) VALUES ('$prefix', 'https://${msfc_server}/demo/index.php/\$1', 1, 0);"
  
   prefix=hosc
   if [ -z $(mysql -u${db_user} -p${db_pass} wiki_poic -sse "select iw_prefix FROM interwiki WHERE iw_prefix='$prefix';") ]; then 
	 echo -e "${info}Value does not exist, creating it${NC}"
   else
     echo -e "${info}Value exists, deleting it first before re-creating it${NC}"
	 mysql -u${db_user} -p${db_pass} wiki_poic -e "DELETE FROM interwiki WHERE iw_prefix='$prefix';" 
   fi     
  mysql -u${db_user} -p${db_pass} wiki_poic -sse "INSERT INTO interwiki (iw_prefix, iw_url, iw_local, iw_trans) VALUES ('$prefix', 'https://${msfc_server}/poic/index.php/\$1', 1, 0);"

   prefix=poic
   if [ -z $(mysql -u${db_user} -p${db_pass} wiki_poic -sse "select iw_prefix FROM interwiki WHERE iw_prefix='$prefix';") ]; then 
	 echo -e "${info}Value does not exist, creating it${NC}"
   else
     echo -e "${info}Value exists, deleting it first before re-creating it${NC}"
	 mysql -u${db_user} -p${db_pass} wiki_poic -e "DELETE FROM interwiki WHERE iw_prefix='$prefix';" 
   fi   
   mysql -u${db_user} -p${db_pass} wiki_poic -sse "INSERT INTO interwiki (iw_prefix, iw_url, iw_local, iw_trans) VALUES ('$prefix', 'https://${msfc_server}/poic/index.php/\$1', 1, 0);"
  #JSC Entries
   prefix=fod_general
   if [ -z $(mysql -u${db_user} -p${db_pass} wiki_poic -sse "select iw_prefix FROM interwiki WHERE iw_prefix='$prefix';") ]; then 
	 echo -e "${info}Value does not exist, creating it${NC}"
   else
     echo -e "${info}Value exists, deleting it first before re-creating it${NC}"
	 mysql -u${db_user} -p${db_pass} wiki_poic -e "DELETE FROM interwiki WHERE iw_prefix='$prefix';" 
   fi   
   mysql -u${db_user} -p${db_pass} wiki_poic -sse "INSERT INTO interwiki (iw_prefix, iw_url, iw_local, iw_trans) VALUES ('$prefix', 'https://wiki.jsc.nasa.gov/fod/index.php/\$1', 1, 0);"

   prefix=fod_iss
   if [ -z $(mysql -u${db_user} -p${db_pass} wiki_poic -sse "select iw_prefix FROM interwiki WHERE iw_prefix='$prefix';") ]; then 
	 echo -e "${info}Value does not exist, creating it${NC}"
   else
     echo -e "${info}Value exists, deleting it first before re-creating it${NC}"
	 mysql -u${db_user} -p${db_pass} wiki_poic -e "DELETE FROM interwiki WHERE iw_prefix='$prefix';" 
   fi   
   mysql -u${db_user} -p${db_pass} wiki_poic -sse "INSERT INTO interwiki (iw_prefix, iw_url, iw_local, iw_trans) VALUES ('$prefix', 'https://wiki.jsc.nasa.gov/iss/index.php/\$1', 1, 0);"
  #External Entries
   prefix=w
   if [ -z $(mysql -u${db_user} -p${db_pass} wiki_poic -sse "select iw_prefix FROM interwiki WHERE iw_prefix='$prefix';") ]; then 
	 echo -e "${info}Value does not exist, creating it${NC}"
   else
     echo -e "${info}Value exists, deleting it first before re-creating it${NC}"
	 mysql -u${db_user} -p${db_pass} wiki_poic -e "DELETE FROM interwiki WHERE iw_prefix='$prefix';" 
   fi   
   mysql -u${db_user} -p${db_pass} wiki_poic -sse "INSERT INTO interwiki (iw_prefix, iw_url, iw_local, iw_trans) VALUES ('$prefix', 'https://en.wikipedia.org/wiki/\$1', 1, 0);"

   prefix=mw
   if [ -z $(mysql -u${db_user} -p${db_pass} wiki_poic -sse "select iw_prefix FROM interwiki WHERE iw_prefix='$prefix';") ]; then 
	 echo -e "${info}Value does not exist, creating it${NC}"
   else
     echo -e "${info}Value exists, deleting it first before re-creating it${NC}"
	 mysql -u${db_user} -p${db_pass} wiki_poic -e "DELETE FROM interwiki WHERE iw_prefix='$prefix';" 
   fi   
   mysql -u${db_user} -p${db_pass} wiki_poic -sse "INSERT INTO interwiki (iw_prefix, iw_url, iw_local, iw_trans) VALUES ('$prefix', 'https://www.mediawiki.org/wiki/\$1', 1, 0);"
  echo -ne "${info}InterWiki Table${NC}: "
  mysql -u${db_user} -p${db_pass} wiki_poic -e "SELECT * FROM interwiki;"
}
##### END   INTERWIKI TABLE
#################################
install_meza_base
install_mediawiki_extensions
meza_public_init
add_wikis
#create_admin
set_interwiki