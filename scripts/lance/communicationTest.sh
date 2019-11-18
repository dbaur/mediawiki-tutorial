DB_HOST="0.0.0.0"
if [ -z ${PUBLIC_LANCEREQUIRESFAAS+123} ] ; then
        MESSAGE="Environment variable PUBLIC_LANCEREQUIRESFAAS required, but not set."
        echo $MESSAGE
        exit 3
elif [ -z ${PUBLIC_LANCEREQUIRESFAAS} ] ; then
        echo "Environment variable LANCEREQUIRESFAAS required, but not set to reasonable value."
        exit 3
else
        arr=$(echo $PUBLIC_LANCEREQUIRESFAAS | tr "," "\n")
        for x in $arr
        ## take the last one (because there are only one)
        do
                echo "PUBLIC_LANCEREQUIRESFAAS > [$x]"
                DB_HOST=$(echo "$x" | sed -e "s/:.*$//")
        done
fi
