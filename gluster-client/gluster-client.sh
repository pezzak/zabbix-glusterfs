#!/bin/bash

#Gluster client status

METRIC=$1

if [[ -z "$1" ]]; then
    echo "Please choose metric"
    exit 1
fi

case $METRIC in
    'check-endpoint')
        endpoint=$2
        test -z "$endpoint" && echo 'Endpoint not specified' && exit 1
        echo $(df | grep -q $endpoint; echo $?)
        ;;
    'discover-endpoint')
        mountpoints=$(egrep -e '\sglusterfs\s' /etc/fstab|grep -v ^# |awk '{print $2}')
        echo -n '{"data":['
        for mount in $mountpoints; do echo -n "{\"{#MOUNT}\": \"$mount\"},"; done |sed -e 's:\},$:\}:'
        echo -n ']}'
        ;;
    *)
        echo "Metric not selected"
        exit 1
        ;;
esac

exit 0
