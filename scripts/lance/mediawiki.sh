#!/bin/bash

MY_DIR="$(dirname "$0")"


### main logic ###
case "$1" in
  configure)
        DB_HOST="0.0.0.0"
        if [ -z ${PUBLIC_WIKIREQMARIADB+123} ] ; then
                MESSAGE="Environment variable PUBLIC_WIKIREQMARIADB required, but not set."
                echo $MESSAGE
                exit 3
        elif [ -z ${PUBLIC_WIKIREQMARIADB} ] ; then
                echo "Environment variable PUBLIC_WIKIREQMARIADB required, but not set to reasonable value."
                exit 3
        else
                arr=$(echo $PUBLIC_WIKIREQMARIADB | tr "," "\n")
                for x in $arr
                ## take the last one (because there are only one)
                do
                        echo "PUBLIC_WIKIREQMARIADB > [$x]"
                        DB_HOST=$(echo "$x" | sed -e "s/:.*$//")
                done
        fi
        ./${MY_DIR}/../shell/mediawiki.sh configure $DB_HOST
        ;;
  *)
        ./${MY_DIR}/../shell/mediawiki.sh $@
esac
