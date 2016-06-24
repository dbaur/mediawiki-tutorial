#!/bin/bash

# Usage
#./mediawiki.sh <db_ip>

# Download URL for mediawiki
MW_DOWNLOAD_URL="https://releases.wikimedia.org/mediawiki/1.26/mediawiki-1.26.2.tar.gz"

# Database
DB="wiki"
DB_USER="wiki"
DB_PASS="password"
DB_HOST=$1

# Wiki
NAME="dbaur"
PASS="admin1345"

if ! [[ -n "$DB_HOST" ]]; then
    echo "argument error"
    exit 1
fi

# Updated apt-get
sudo apt-get --yes update && sudo apt-get --yes upgrade
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
# restart apache server
sudo service apache2 restart
# run mediawiki installation skript
php mediawiki/maintenance/install.php --dbuser ${DB_USER} --dbpass ${DB_PASS} --dbname ${DB} --dbserver ${DB_HOST} --pass ${PASS} $NAME "admin"
