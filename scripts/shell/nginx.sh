#!/bin/bash

MY_DIR="$(dirname "$0")"
source "$MY_DIR/util.sh"

# usage
#./nginx.sh <ip> <ip> ...

IPS=${@:2}

install() {
    # update apt-get
    apt_update

    # install nginx
    nginx=stable
    sudo add-apt-repository ppa:nginx/$nginx -y
    sudo apt-get --yes update
    sudo apt-get --yes install nginx

    sudo service nginx stop
}

configure() {

if ! [[ -n "$IPS" ]]; then
    echo "Expected list of ips as parameter but got none."
    exit 1
fi

# write nginx configuration
rm -rf wiki.tmp
touch wiki.tmp

echo 'upstream wiki {' >> wiki.tmp

for var in "$IPS"
do
    echo "    server $var:80;" >> wiki.tmp
done

echo '}' >> wiki.tmp
echo 'server {' >> wiki.tmp
echo '    listen 8080;' >> wiki.tmp
echo '    location / {' >> wiki.tmp
echo '      proxy_pass http://wiki;' >> wiki.tmp
echo '    }' >> wiki.tmp
echo '  }' >> wiki.tmp

sudo mv wiki.tmp /etc/nginx/sites-available/wiki.conf
sudo rm -f /etc/nginx/sites-enabled/wiki
sudo ln -s /etc/nginx/sites-available/wiki.conf /etc/nginx/sites-enabled/wiki
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
