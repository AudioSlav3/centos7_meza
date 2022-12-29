#!/bin/bash
db_user=wiki_app_user
db_pass=$1
echo "">wikiusers.txt
user_count=0
wiki_select=wiki_poic
exit_status=1
wiki_name=( $(mysql -u${db_user} -p${db_pass} -se "show databases"| grep wiki) )

get_users () {
  mysql -u${db_user} -p${db_pass} ${wiki_select} -sse "SELECT user_name FROM user" >wikiusers.txt
}
show_wiki_users () {
while [ $exit_status = 1 ]; do
  dialog --keep-window --begin 10 50 --tailboxbg wikiusers.txt 35 40 \
       --and-widget \
       --keep-window --begin 1 50 --infobox "Users: ${user_count}" 5 40 \
       --and-widget \
       --keep-window --no-items --default-item "$wiki_select" --begin 1 5 --menu "Menu" 40 40 20 ${wiki_name[*]} 2>wikiselect
  wiki_select=$(cat wikiselect)
  rm wikiselect
  get_users
  if [ $? = 1 ]; then
    exit_status=0
  fi
  user_count=$(wc -l wikiusers.txt | cut -d " " -f 1)
done
clear
}

show_wiki_users
