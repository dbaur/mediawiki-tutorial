#!/bin/bash

MY_DIR="$(dirname "$0")"
source "$MY_DIR/util.sh"

ROOT_PW="topsecret"
DB="wiki"
DB_USER="wiki"
DB_PASS="password"

install() {
    apt_update
    #set default root password for automated installation
    sudo debconf-set-selections <<< 'mariadb-server mysql-server/root_password password '${ROOT_PW}
    sudo debconf-set-selections <<< 'mariadb-server mysql-server/root_password_again password '${ROOT_PW}
    sudo apt-get --yes install mariadb-server
    sudo service mysql stop
}

start() {
    sudo service mysql start
}

startBlocking() {
    sudo service mysql start && sleep infinity
}


configure() {
    sudo service mysql start

    #create database
    mysql -u root -p${ROOT_PW} -e "CREATE DATABASE $DB;"

    #create user and grant privileges
    mysql -u root -p${ROOT_PW} -e "GRANT ALL PRIVILEGES ON $DB.* TO '$DB_USER'@'%' IDENTIFIED BY '$DB_PASS';";
    mysql -u root -p${ROOT_PW} -e "FLUSH PRIVILEGES;"

    #configure bind address
    sudo sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

    sudo service mysql stop
}

stop() {
    sudo service mysql stop
}

### main logic ###
case "$1" in
  install)
        install
        ;;
  start)
        start
        ;;
  startBlocking)
        startBlocking
        ;;
  configure)
        configure
        ;;
  stop)
        stop
        ;;
  *)
        echo $"Usage: $0 {install|start|startBlocking|configure|stop}"
        exit 1
esac
