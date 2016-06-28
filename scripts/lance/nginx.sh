#!/bin/bash

MY_DIR="$(dirname "$0")"


### main logic ###
case "$1" in
  configure)
        WIKI_HOSTS="0.0.0.0"
        if [ -z ${PUBLIC_LOADBALANCERREQWIKI+123} ] ; then
                MESSAGE="Environment variable PUBLIC_LOADBALANCERREQWIKI required, but not set."
                echo $MESSAGE
                exit 3
        elif [ -z ${PUBLIC_LOADBALANCERREQWIKI} ] ; then
                echo "Environment variable PUBLIC_LOADBALANCERREQWIKI required, but not set to reasonable value."
                exit 3
        else
                arr=$(echo $PUBLIC_LOADBALANCERREQWIKI | tr "," "\n")
                for x in $arr
                ## take the last one (because there are only one)
                do
                        echo "PUBLIC_LOADBALANCERREQWIKI > [$x]"
                        WIKI_HOSTS+=$(echo "$x" | sed -e "s/:.*$//")
                        WIKI_HOSTS+=" "
                done
        fi
        ./${MY_DIR}/../shell/nginx.sh configure $WIKI_HOSTS
        ;;
  *)
        ./${MY_DIR}/../shell/nginx.sh $@
esac
