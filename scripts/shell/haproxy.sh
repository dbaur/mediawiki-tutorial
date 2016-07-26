#!/bin/bash

MY_DIR="$(dirname "$0")"
source "$MY_DIR/util.sh"
TMP_DIR="/tmp"
HA_PROXY_CONFIG_URL="https://raw.githubusercontent.com/dbaur/mediawiki-tutorial/master/config/haproxy.cfg"
RSYSLOG_CONFIG_URL="https://raw.githubusercontent.com/dbaur/mediawiki-tutorial/master/config/haproxyRsyslog.cfg"

IPS=${@:2}

install() {
    apt_update

    #install haproxy
    sudo apt-get -y install haproxy wget

    #enable haproxy
    sudo sed -i "s/ENABLED=0/ENABLED=1/g" /etc/default/haproxy

    #configure rsyslog
    wget ${HA_PROXY_CONFIG_URL} -O ${TMP_DIR}/haproxyRsyslog.tmp
    sudo cp ${TMP_DIR}/haproxyRsyslog.tmp /etc/rsyslog.d/haproxy.cfg

    sudo /etc/init.d/rsyslog restart
    IPS="127.0.0.1"
    configure

    sudo /etc/init.d/haproxy stop

}

configure() {

#validate ips
if ! [[ -n "$IPS" ]]; then
    echo "Expected list of ips as parameter but got none."
    exit 1
fi

# remove existing tmp file
rm -rf ${TMP_DIR}/haproxy.tmp
# download config template
wget ${HA_PROXY_CONFIG_URL} -O ${TMP_DIR}/haproxy.tmp

# write servers into template
i=1
SERVERS=""
for var in ${IPS}
do
    SERVERS+="server wiki$i $var:80 check\\n"
    ((i++))
done
sudo sed -i -e "s/\${servers}/${SERVERS}/" ${TMP_DIR}/haproxy.tmp

# mv temp file to real location
sudo mv /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.bak
sudo mv ${TMP_DIR}/haproxy.tmp /etc/haproxy/haproxy.cfg

# reload haproxy
sudo /etc/init.d/haproxy reload

}

start() {
    # start haproxy
    sudo /etc/init.d/haproxy start
}

startBlocking() {
    # start haproxy and sleep for infinity
    sudo /etc/init.d/haproxy start && sleep infinity
}

stop() {
    # stop haproxy
    sudo /etc/init.d/haproxy stop
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
