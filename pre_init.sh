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
done
sudo su - ${adminuser}
}
#################################
##### SSH Key
update_ssh () {
echo ${USER}
read ans
while ! test -f "${HOME}/ssh.done"; do 
  if ! test -f "${HOME}/add_ssh.sh"; then
    echo -e "${info}#### PERFORM THE FOLLOWING ON YOUR HOST MACHINE ###${NC}"
    echo -e "${info}## open pterm.exe (Putty windows command line) ${NC}"
    echo -e "${info}## run: ${NC}"
    echo -e "${info}## ${purple}pscp.exe ${white}..\..\NASAWiki\vmbuild\${purple}add_ssh.sh ${USER}@${hostname -I}:${HOME}${NC}"
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
sudo cat << 'EOF' > /etc/issue
\S
IP Address: \4
EOF
}
#################################
##### START Install Packages
update_packages () {
 while ! test -f "${HOME}/pkg.done"; do 
	 myNewPackages=()
	 sudo yum update -q
	 centos_7_vbox="gcc make perl bzip2 kernel-headers-$(uname -r) kernel-devel-$(uname -r) elfutils-libelf-devel xorg-x11-drivers xorg-x11-util"
	 centos_7=$centos_7_vbox" screen git nano zip unzip php74-pecl-zip.x86_64 dialog wget"
	 
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
 sudo mkdir /cdrom
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
 done
}
update_sudo
update_ssh
update_misc_settings
update_packages
install_VBoxGuest