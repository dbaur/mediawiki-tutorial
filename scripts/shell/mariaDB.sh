#!/bin/bash

# Usage
#./mariaDB.sh

ROOT_PW="topsecret"
DB="wiki"
DB_USER="wiki"
DB_PASS="password"

# update apt-get
sudo apt-get --yes update && sudo apt-get --yes upgrade

#set default root password for automated installation
sudo debconf-set-selections <<< 'mariadb-server mysql-server/root_password password '${ROOT_PW}
sudo debconf-set-selections <<< 'mariadb-server mysql-server/root_password_again password '${ROOT_PW}
sudo apt-get --yes install mariadb-server

#create database
mysql -u root -p${ROOT_PW} -e "CREATE DATABASE $DB;"

#create user and grant privileges
mysql -u root -p${ROOT_PW} -e "GRANT ALL PRIVILEGES ON $DB.* TO '$DB_USER'@'%' IDENTIFIED BY '$DB_PASS';";
mysql -u root -p${ROOT_PW} -e "FLUSH PRIVILEGES;"

