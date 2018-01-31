#!/bin/bash

#Gluster server status

METRIC=$1
SUDO="/usr/bin/sudo"
PIDOF="/bin/pidof"
GLUSTER="/usr/sbin/gluster"

if [[ -z "$1" ]]; then
    echo "Please choose metric"
    exit 1
fi

case $METRIC in
    'glusterd')
        if ! $PIDOF glusterd &>/dev/null; then
            echo 0
            exit 1
        else
            echo 1
        fi
        ;;
    'glusterfsd')
        if ! $PIDOF glusterfsd &>/dev/null; then
            echo 0
            exit 1
        else
            echo 1
        fi
        ;;
    'discover-peers')
        echo -n '{"data":['
        peers=$($SUDO $GLUSTER peer status | grep '^Hostname: ' | awk '{print $2}')
        for peer in $peers; do
            echo -n "{\"{#PEER}\": \"$peer\"},"
        done | sed -e 's:,$::'
        echo -n ']}'
        ;;
    'check-peer-state')
        peer="$2"
        test -z "$peer" && echo 'Peer not specified' && exit 1
        state=$($SUDO $GLUSTER peer status | \
                grep -A2 $peer | \
                grep '^State: ' | \
                sed -nre 's/State: ([[:graph:]])/\1/p')
        test -z "$state" && echo 'Peer not found' && exit 1
        echo $state
        ;;
    'discover-volumes')
        echo -n '{"data":['
        volumes=$($SUDO $GLUSTER volume list)
        for volume in $volumes; do
            bricks=$($SUDO $GLUSTER volume heal $volume info | \
                     grep 'Brick' | \
                     awk '{print $2}')
            for brick in $bricks; do
                echo -n "{\"{#VOLUME}\": \"$volume\", \"{#BRICK}\": \"$brick\"},"
            done
        done | sed -e 's:,$::'
        echo -n ']}'
        ;;
    'volume-heal-info')
        volume=$2
        brick=$3
        test -z "$volume" && echo 'Volume not specified' && exit 1
        test -z "$brick" && echo 'Brick not specified' && exit 1
        entries=$($SUDO $GLUSTER volume heal $volume info | \
                grep -A3 $brick | \
                grep '^Number of entries: ' | \
                sed -nre 's/Number of entries: ([[:graph:]])/\1/p')
        test -z "$entries" && echo 'Brick not found' && exit 1
        echo $entries
        ;;
    'volume-heal-info-splitbrain')
        volume=$2
        brick=$3
        test -z "$volume" && echo 'Volume not specified' && exit 1
        test -z "$brick" && echo 'Brick not specified' && exit 1
        entries=$($SUDO $GLUSTER volume heal $volume info split-brain | \
                grep -A3 $brick | \
                grep '^Number of entries in split-brain: ' | \
                sed -nre 's/Number of entries in split-brain: ([[:graph:]])/\1/p')
        test -z "$entries" && echo 'Brick not found' && exit 1
        echo $entries
        ;;
    'volume-status-offline')
        volume=$2
        test -z "$volume" && echo 'Volume not specified' && exit 1
        offline=$($SUDO $GLUSTER volume status $volume | \
                grep -e ".*\sN\s.*" | \
                wc -l)
        echo $offline
        ;;
    *)
        echo "Metric not selected"
        exit 1
        ;;
esac

exit 0
