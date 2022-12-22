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
}
update_meza_ext () {
  sudo meza deploy monolith --tags mediawiki --skip-tags mediawiki-core,verify-wiki
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
	
	touch ${HOME}/meza_base.done
	echo -e "${ok}MEZA Wiki installed.${NC}"
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
	touch ${HOME}/mediawiki_extension.done
	echo -e "${ok}Done.${NC}"
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
   touch ${HOME}/meza_config_init.done
   echo -e "${ok}Done.${NC}"
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

 while IFS='|' read -r wikisection wikiid wikititle
 do
  if ! $(echo $wikisection | grep -q "#"); then 
	if ! test -d "/opt/conf-meza/public/wikis/$wikiid/"; then 
	  echo -e "${update}Deploying Wiki:${NC}"
      echo -e "${cyan}        $wikiid, $wikititle${NC}"
	  case $wikiid in 
	    poic)
		  sudo meza create wiki-promptless monolith $wikiid "HOSC Wiki"
		  cfg_updt=0
		;;
		science)
		  sudo meza create wiki-promptless monolith $wikiid "Science"
		  cfg_updt=0
		;;
		cadre)
		  sudo meza create wiki-promptless monolith $wikiid "POIC Cadre"
		  cfg_updt=0
		;;
	  esac
	  echo -e "${update}Copying icon and image to Wiki${purple} $wikiid${NC}"
	  sudo cp $delta_config_file_dirs/wikis/$wikiid/* /opt/conf-meza/public/wikis/$wikiid/
	else
	   echo -e "----- ${ok}$wikiid already deployed.${NC}"
	fi 
  fi
 done < $variable_dirs/wikis.txt

 if [ "$cfg_updt" = "0" ]; then 
   echo -e "${update}Applying config to apply new images.${NC}"
   update_meza_config
   echo -e "${ok}Done.${NC}"
 fi
}

##### END   
#################################
##### START 

#################################
##### START Write public files
meza_public_updt () {
 if test -f "${HOME}/meza_config_updt.done"; then
   echo -e "${ok}Update to custom public.yml already complete.${NC}"
 else
   echo -e "${update}Copying delta public configs for Wiki.${NC}"
   sudo rsync -av --exclude='wikis' $delta_config_file_dirs/ /opt/conf-meza/public/
   #set demo wiki for anyone to read
   echo -e "${update}Updating demo base.php to allow anyone to read Wiki.${NC}"
   sudo sed -i 's/\/\/ $mezaAuthType = \x27viewer-read\x27;/$mezaAuthType = \x27anon-read\x27;/g' /opt/conf-meza/public/wikis/demo/preLocalSettings.d/base.php
   echo -e "${update}Applying config changes.${NC}"
   update_meza_config
   touch ${HOME}/meza_config_updt.done
   echo -e "${ok}Done.${NC}"
 fi
}
##### END   
#################################
##### START 

##### END   
#################################
##### START CODE HOLD

 # if ! check_hash $config_file_dirs/public.yml $init_file ; then
    # echo -e "${warn}${NC}Checksum failed, fixing"
	###write file with 'demo' as default wiki
	#sudo cp -f $config_file_dirs/public.yml $init_file
 # else
    # echo -e "${ok}${NC}Checksum OK"
 # fi
 
  
  # init_file=/opt/conf-meza/public/primewiki
 # if [[ ! $(echo "$init_public_yml $init_file" | sha1sum -c ) ]]; then
    # echo -e "${warn}${NC}Checksum failed, fixing"
	###write file with 'demo' as default wiki
	
	# cat << 'EOF' > ${init_file}
# demo
# EOF
 # else
    # echo -e "${ok}${NC}Checksum OK"	
 # fi
 
 
 
 
# header_wikis+=('  - demo'\\n)
	  #sudo meza create wiki-promptless monolith $wikiid '"'$wikititle'"' 
	# if [ "$wikisection" = "header" ]; then  
		# header_wikis+=(${wikiid})
	# fi
	# if [ "$wikisection" = "middle" ]; then  
		# middle_wikis+=(${wikiid})
	# fi
	# if [ "$wikisection" = "footer" ]; then  
		# footer_wikis+=(${wikiid})
	# fi
#header_wikis+=(\\n)
#footer_wikis+=(\\n)
 # echo -e "${cyan}Header Wikis:${NC}"
 # echo '"'${header_wikis[@]}'"'
 # echo -e "${cyan}Middle Wikis:${NC}"
 # echo '"'${middle_wikis[@]}'"'
 # echo -e "${cyan}Footer Wikis:${NC}"
 # echo '"'${footer_wikis[@]}'"'
# sed -n "/blender_header_wikis:/{p;:a;N;/\n# blender_middle_wiki_title/!ba;s/.*\n/${header_wikis[*]}\n/};p" /opt/conf-meza/public/public.yml
# sed -n "/blender_footer_wikis:/{p;:a;N;/\n# blender_footer_wikis/!ba;s/.*\n/${footer_wikis[*]}\n/};p" /opt/conf-meza/public/public.yml
 
 
##### END   CODE HOLD
#################################
install_meza_base
install_mediawiki_extensions
meza_public_init
add_wikis
meza_public_updt