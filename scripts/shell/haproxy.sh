#!/bin/bash

MY_DIR="$(dirname "$0")"
source "$MY_DIR/util.sh"
TMP_DIR="/tmp"
HA_PROXY_CONFIG_URL="https://raw.githubusercontent.com/dbaur/mediawiki-tutorial/master/config/haproxy.cfg"
RSYSLOG_CONFIG_URL="https://raw.githubusercontent.com/dbaur/mediawiki-tutorial/master/config/haProxyRsyslog.cfg"

IPS=${@:2}

install() {
    apt_update

    #install haproxy
    apt-get -y install haproxy wget

    #enable haproxy
    sed -i "s/ENABLED=0/ENABLED=1/g" /etc/default/haproxy

    #configure rsyslog
    wget ${RSYSLOG_CONFIG_URL} -O ${TMP_DIR}/haProxyRsyslog.tmp
    cp ${TMP_DIR}/haProxyRsyslog.tmp /etc/rsyslog.d/haproxy.conf

    /etc/init.d/rsyslog stop
    /etc/init.d/rsyslog restart
    IPS="127.0.0.1"
    configure

    /etc/init.d/haproxy stop

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
sed -i -e "s/\${servers}/${SERVERS}/" ${TMP_DIR}/haproxy.tmp

# mv temp file to real location
mv /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.bak
mv ${TMP_DIR}/haproxy.tmp /etc/haproxy/haproxy.cfg

# reload haproxy
/etc/init.d/haproxy reload

}

start() {
    # start haproxy
    /etc/init.d/haproxy start
}

startBlocking() {
    # start haproxy and sleep for infinity
    /etc/init.d/haproxy start && sleep infinity
}

stop() {
    # stop haproxy
    /etc/init.d/haproxy stop
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
