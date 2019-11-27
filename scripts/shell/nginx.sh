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
    add-apt-repository ppa:nginx/$nginx -y
    apt-get --yes update
    apt-get --yes install nginx

    rm -f /etc/nginx/sites-enabled/*

    service nginx stop
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

for var in ${IPS}
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

mv ${TMP_DIR}/wiki.tmp /etc/nginx/sites-available/wiki.conf
rm -f /etc/nginx/sites-enabled/*
ln -s /etc/nginx/sites-available/wiki.conf /etc/nginx/sites-enabled/wiki

}

start() {
    # start nginx
    service nginx start
}

startBlocking() {
    service nginx start && sleep infinity
}

stop() {
    service nginx stop
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
