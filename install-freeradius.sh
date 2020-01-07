#!/bin/sh
# Created by WHMCS-Smarters www.whmcssmarters.com

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
SYS_DT=$(date +%F-%T)

exiterr()  { echo "Error: $1" >&2; exit 1; }
exiterr2() { exiterr "'apt-get install' failed."; }
conf_bk() { /bin/cp -f "$1" "$1.old-$SYS_DT" 2>/dev/null; }
bigecho() { echo; echo "## $1"; echo; }

while getopts ":h:p:l:s:d:" o
do
    case "${o}" in
    h) MYSQLHOST=${OPTARG}
    ;;
    p) MYSQLPORT=${OPTARG}
    ;;
    l) MYSQLLOGIN=${OPTARG}
	;;
	s) MYSQLPASS=${OPTARG}
	;;
	d) MYSQLDB=${OPTARG}
	esac
done

if [ -z "$MYSQLPORT" ]; then
	MYSQLPORT=3306
fi


bigecho "Freeradius Installation Started ......"

# check if alredy installed, so need to be removed first 

 
if [ -e "/etc/freeradius/3.0/mods-enabled/sql" ];then 

bigecho "We found freeradius folder seems it's already installed. So it need to be removed first"

sudo systemctl stop freeradius.service # stopping freeradius first

# sudo apt-get -y remove freeradius
# sudo apt-get -y remove --auto-remove freeradius
# sudo apt-get -y purge freeradius
# sudo apt-get purge -y --auto-remove freeradius
rm /etc/freeradius/3.0/mods-enabled/sql


bigecho "Removed Freeradius Successfully"

fi
apt-get -yq update
sudo apt -y install freeradius freeradius-mysql freeradius-utils

bigecho "Passing variables are : mysqlhost - $MYSQLHOST , mysqldatabase : $MYSQLDB, mysqlport $MYSQLPORT , mysqusername : $MYSQLLOGIN , mysqlpassword : $MYSQLPASS"

cat >> /etc/freeradius/3.0/mods-enabled/sql <<EOF 
sql {
driver = "rlm_sql_mysql"
dialect = "mysql"

# Connection info:
server = "$MYSQLHOST"
port = $MYSQLPORT
login = "$MYSQLLOGIN"
password = "$MYSQLPASS"

# Database table configuration for everything except Oracle
radius_db = "$MYSQLDB"
}

# Set to ‘yes’ to read radius clients from the database (‘nas’ table)
# Clients will ONLY be read on server startup.
read_clients = yes

# Table to keep radius client info
client_table = "nas"

EOF

#/etc/freeradius/3.0/mods-enabled/sql

echo  "setting up the premission...."

sudo chgrp -h freerad /etc/freeradius/3.0/mods-available/sql
sudo chown -R freerad:freerad /etc/freeradius/3.0/mods-enabled/sql
sudo systemctl restart freeradius.service
