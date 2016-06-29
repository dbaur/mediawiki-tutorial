#!/bin/bash

MY_DIR="$(dirname "$0")"
source "$MY_DIR/util.sh"

TMP_DIR="/tmp"

IPS=${@:2}

install() {
    # update apt-get
    apt_update

    # install nginx
    nginx=stable
    sudo add-apt-repository ppa:nginx/$nginx -y
    sudo apt-get --yes update
    sudo apt-get --yes install nginx

    sudo rm -f /etc/nginx/sites-enabled/*

    sudo service nginx stop
}

configure() {

if ! [[ -n "$IPS" ]]; then
    echo "Expected list of ips as parameter but got none."
    exit 1
fi

# write nginx configuration
rm -rf ${TMP_DIR}/wiki.tmp
touch ${TMP_DIR}/wiki.tmp

echo 'upstream wiki {' >> ${TMP_DIR}/wiki.tmp

for var in "$IPS"
do
    echo "    server $var:80;" >> ${TMP_DIR}/wiki.tmp
done

echo '}' >> ${TMP_DIR}/wiki.tmp
echo 'server {' >> ${TMP_DIR}/wiki.tmp
echo '    listen 80;' >> ${TMP_DIR}/wiki.tmp
echo '    location / {' >> ${TMP_DIR}/wiki.tmp
echo '      proxy_pass http://wiki;' >> ${TMP_DIR}/wiki.tmp
echo '    }' >> ${TMP_DIR}/wiki.tmp
echo '  }' >> ${TMP_DIR}/wiki.tmp

sudo mv ${TMP_DIR}/wiki.tmp /etc/nginx/sites-available/wiki.conf
sudo rm -f /etc/nginx/sites-enabled/*
sudo ln -s /etc/nginx/sites-available/wiki.conf /etc/nginx/sites-enabled/wiki

sudo service nginx reload

}

start() {
    # start nginx
    sudo service nginx start
}

startBlocking() {
    sudo service nginx start && sleep infinity
}

stop() {
    sudo service nginx stop
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
