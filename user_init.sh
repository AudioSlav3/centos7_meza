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
adminuser=null

#################################
##### SSH Key
update_ssh () {
while ! test -f "${HOME}/ssh.done"; do 
  if ! test -f "${HOME}/add_ssh.sh"; then
    echo -e "${info}#### PERFORM THE FOLLOWING ON YOUR HOST MACHINE ###${NC}"
    echo -e "${info}## open pterm.exe (Putty windows command line) ${NC}"
    echo -e "${info}## run the following ${NC}"
    echo -e "${info}## ${purple}pscp.exe ${white}..\..\NASAWiki\\\vmcommon\\\\${purple}add_ssh.sh${white} ${USER}@$(hostname -I|xargs):${HOME}${NC}"
    echo -e "${info}######################################${NC}"
    echo -e "${brown} Press [ENTER] ONLY AFTER completing ALL of the above.${NC}" 
    read ans
  fi
  if test -f "${HOME}/add_ssh.sh"; then
    bash ${HOME}/add_ssh.sh
	touch ${HOME}/ssh.done
    echo -e "${update}Added SSH Key, you may verify your config by attempting to ssh with key.${NC}"
  fi
done
}
#################################
##### MISC Settings
update_misc_settings () {
 while ! test -f "${HOME}/misc.done"; do 
  sudo sed -i 's/Kernel \\r on an \\m/IP Address: \\4/g' /etc/issue
  touch ${HOME}/misc.done
 done
}
#################################
##### START Install Packages
update_packages () {
 while ! test -f "${HOME}/pkg.done"; do 
	 myNewPackages=()
	 sudo yum -y install deltarpm
	 sudo yum update -q -y
	 centos_7_vbox="gcc make perl bzip2 kernel-headers kernel-devel-$(uname -r) elfutils-libelf-devel xorg-x11-drivers xorg-x11-utils libXt.x86_64 libXmu"
	 centos_7=$centos_7_vbox" screen nano zip unzip dialog git wget tar"
	 
	 centos_8_vbox="tar gcc make perl bzip2 kernel-headers-$(uname -r) kernel-devel-$(uname -r) elfutils-libelf-devel xorg-x11-drivers xorg-x11-utils.x86_64 libXt.x86_64"
	 centos_8=$centos_8_vbox" git nano zip unzip dialog"
	 
	 centos_9_vbox="gcc make perl bzip2 kernel-headers-$(uname -r) kernel-devel-$(uname -r) elfutils-libelf-devel xorg-x11-drivers  xorg-x11-utils.x86_64"
	 centos_9=$centos_9_vbox" git nano zip unzip dialog wget"
	 
	 #Choose which centos version to pull from.
	 centos_ver=$centos_7
	 
	 #Begin package installs
	 for t in $centos_ver; do  
	  if sudo yum --cacheonly list ${t} | grep -q "Installed Packages";  then
        echo -e "${ok}${t} already installed${NC}"
      else		
		echo -e "${update}${CYAN}Adding ${BLUE}${t}${CYAN} to install package${NC}"
		myNewPackages+=( ${t} )
	  fi
	 done
	 if [ ${#myNewPackages[@]} -gt 0 ]; then
	  echo -e "${update}${CYAN}Installing Apps: ${BLUE}${myNewPackages[@]}${NC}"
	  sudo yum -y install ${myNewPackages[@]}
	 else
	  echo -e "${ok}${GREEN}No Packages to Install${NC}"
	 fi
	 touch ${HOME}/pkg.done
 done
}

install_VBoxGuest () {
 #Mount and install Guest Additions
 if ! test -d /cdrom ; then
   sudo mkdir /cdrom
 fi
 while ! test -f "${HOME}/vbox.done"; do 
 rom_array=($(ls /dev/sr*))
 len=${#rom_array[@]}
 ans=99
 until [[ ! -z "${rom_array[$ans]}" ]]; do 
   for (( i=0; i<$len; i++ )); do printf "$i) %s\n"  "${rom_array[$i]}" ; done
   echo -e "${brown} Which one is VBoxGuestAdditions on? (ex, if on sr1, then input  ${NC}" 
   read ans; 
 done; 
 if [ $ans -gt $len ]; then 
   echo "invalid"
 fi
 sudo mount ${rom_array[$ans]} /cdrom
 if test -f /cdrom/VBoxLinuxAdditions.run ; then 
   sudo /cdrom/VBoxLinuxAdditions.run
   touch ${HOME}/vbox.done
 fi 
 echo -e "${info}Waiting 10 seconds for mount."
 sleep 10
 if  [ "$(sudo ls -A /mnt)" ]; then 
   echo -e "${ok}Successfully mount detected"
 fi
 done
}
update_ssh
update_misc_settings
update_packages
install_VBoxGuest
if test -f "${HOME}/ssh.done" && test -f "${HOME}/misc.done" && test -f "${HOME}/pkg.done" && test -f "${HOME}/vbox.done"; then 
  echo -e "${ok}All user settings applied"
  echo -e "${cyan} Ready to run meza_init.sh${NC}"
else
  echo -e "${warn}Not all applied, check settings before proceeding."
fi
