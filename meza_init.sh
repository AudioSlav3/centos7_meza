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
config_file_dirs="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)/meza_public"
# sha1sum $config_file_dirs/<subfolder>/<file> | cut -d " " -f1|xargs

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


#################################
##### MISC Settings
# update_misc_settings () {

# }
update_mediawiki_extensions () {
cd /opt/htdocs/mediawiki
sudo su meza-ansible -c "/usr/local/bin/composer update"
}
##### END Install Packages
#################################
##### START Write public files
meza_public_update () {
 if ! check_hash $config_file_dirs/public.yml $init_file ; then
    echo -e "${warn}${NC}Checksum failed, fixing"
	#write file with 'demo' as default wiki

 else
    echo -e "${ok}${NC}Checksum OK"
 fi
 
  init_public_yml=9ad4cf12ea8c7c42000a7af92864e80e807a0718
  init_file=/opt/conf-meza/public/primewiki
 if [[ ! $(echo "$init_public_yml $init_file" | sha1sum -c ) ]]; then
    echo -e "${warn}${NC}Checksum failed, fixing"
	#write file with 'demo' as default wiki
	
	cat << 'EOF' > ${init_file}
demo
EOF
 else
    echo -e "${ok}${NC}Checksum OK"	
 fi
}
##### END   Write public files
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
##### START 

##### END   
#################################
install_meza_base
#update_packages
#meza_public_update