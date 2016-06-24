#!/bin/bash

MY_DIR="$(dirname "$0")"
source "$MY_DIR/util.sh"

# Download URL for mediawiki
MW_DOWNLOAD_URL="https://releases.wikimedia.org/mediawiki/1.26/mediawiki-1.26.2.tar.gz"

# Database
DB="wiki"
DB_USER="wiki"
DB_PASS="password"
DB_HOST=$2

# Wiki
NAME="dbaur"
PASS="admin1345"

install() {
    apt_update
    # Install dependencies (apache2, php5, php5-mysql)
    sudo apt-get --yes install apache2 php5 php5-mysql
    # remove existing mediawiki archive
    rm -f mediawiki.tar.gz
    # download mediawiki tarball
    wget ${MW_DOWNLOAD_URL} -O mediawiki.tar.gz
    # remove existing mediawiki folder
    rm -rf mediawiki
    mkdir mediawiki
    # extract mediawiki tarball
    tar -xvzf mediawiki.tar.gz -C mediawiki --strip-components=1
    # remove existing mediawiki symbolic link
    sudo rm -rf /var/www/html/wiki
    # create symbolic link
    sudo ln -s ~/mediawiki /var/www/html/wiki
    # stop apache
    sudo service apache2 stop
}

configure() {
    if ! [[ -n "$DB_HOST" ]]; then
        echo "you need to supply a db host"
        exit 1
    fi
    sudo service apache2 start
    # run mediawiki installation skript
    php mediawiki/maintenance/install.php --dbuser ${DB_USER} --dbpass ${DB_PASS} --dbname ${DB} --dbserver ${DB_HOST} --pass ${PASS} $NAME "admin"
    sudo service apache2 stop
}

start() {
    sudo service apache2 start
}

startBlocking() {
    sudo service apache2 start && sleep infinity
}

stop() {
    sudo service apache stop
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
