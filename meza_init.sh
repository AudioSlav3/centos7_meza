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
  if ! test -d "/opt/meza"; then
     sudo git clone https://github.com/enterprisemediawiki/meza /opt/meza
  fi
  while ! test -f "${HOME}/meza_base.done"; do 
    sudo bash /opt/meza/src/scripts/getmeza.sh
	sudo meza deploy monolith
	
	touch ${HOME}/meza_base.done
  done
}

install_mediawiki_extensions () {
  while ! test -f "${HOME}/mediawiki_extension.done"; do 
    sudo cp $config_file_dirs/MezaLocalExtensions.yml /opt/conf-meza/public/
	update_meza_ext
	
	touch ${HOME}/mediawiki_extension.done
  done
}


#################################
##### MISC Settings
# update_misc_settings () {

# }
# update_mediawiki_extensions () {
# cd /opt/htdocs/mediawiki
# sudo su meza-ansible -c "/usr/local/bin/composer update"
# }
##### END


#################################
##### START Write public files
meza_public_init () {
 while ! test -f "${HOME}/meza_config_init.done"; do 
 sudo cp -R $config_file_dirs/* /opt/conf-meza/public/
 
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
 update_meza_config
 touch ${HOME}/meza_config_init.done
 done
}
##### END   Write public files
#################################
##### START WIKI Deploy
add_wikis () {
 #Read File to use in deploy
 header_wikis=()
 middle_wikis=()
 footer_wikis=()
# header_wikis+=('  - demo'\\n)
 echo -e "${cyan}File Contents:${NC}"
 while IFS='|' read -r wikisection wikiid wikititle
 do
  if ! $(echo $wikisection | grep -q "#"); then 
    echo "$wikisection, $wikiid, $wikititle"
	if ! test -d "/opt/conf-meza/public/wikis/$wikiid/"; then 
	  sudo meza create wiki-promptless monolith $wikiid '"'$wikititle'"'
	  sudo cp $delta_config_file_dirs/wikis/$wikiid/* /opt/conf-meza/public/wikis/$wikiid/
	fi 
	if [ "$wikisection" = "header" ]; then  
		header_wikis+=(${wikiid})
	fi
	if [ "$wikisection" = "middle" ]; then  
		middle_wikis+=(${wikiid})
	fi
	if [ "$wikisection" = "footer" ]; then  
		footer_wikis+=(${wikiid})
	fi
  fi
 done < $variable_dirs/wikis.txt
#header_wikis+=(\\n)
#footer_wikis+=(\\n)
 echo -e "${cyan}Header Wikis:${NC}"
 echo '"'${header_wikis[@]}'"'
 echo -e "${cyan}Middle Wikis:${NC}"
 echo '"'${middle_wikis[@]}'"'
 echo -e "${cyan}Footer Wikis:${NC}"
 echo '"'${footer_wikis[@]}'"'
 update_meza_config
# sed -n "/blender_header_wikis:/{p;:a;N;/\n# blender_middle_wiki_title/!ba;s/.*\n/${header_wikis[*]}\n/};p" /opt/conf-meza/public/public.yml
# sed -n "/blender_footer_wikis:/{p;:a;N;/\n# blender_footer_wikis/!ba;s/.*\n/${footer_wikis[*]}\n/};p" /opt/conf-meza/public/public.yml
}

##### END   
#################################
##### START 

##### END   
#################################
##### START 

##### END   
#################################
##### START 

##### END   
#################################
install_meza_base
install_mediawiki_extensions
meza_public_init
#add_wikis