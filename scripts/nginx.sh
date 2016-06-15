#!/bin/bash

# usage
#./nginx.sh <ip> <ip> ...

ARGS=$@

if ! [[ -n "$ARGS" ]]; then
    echo "argument error"
    exit 1
fi

# update apt-get
sudo apt-get --yes update && sudo apt-get --yes upgrade

# install nginx
nginx=stable
sudo add-apt-repository ppa:nginx/$nginx -y
sudo apt-get --yes update
sudo apt-get --yes install nginx

# start nginx
sudo service nginx start

# write nginx configuration
rm -rf wiki.tmp
touch wiki.tmp

echo 'upstream wiki {' >> wiki.tmp

for var in "$ARGS"
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

# restart nginx
sudo service nginx restart
