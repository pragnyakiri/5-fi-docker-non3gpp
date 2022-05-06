#!/bin/bash

set -e

if [ $# -lt 1 ]
then
        echo "Usage : $0 [gnb|ue]"
        exit
fi

command=$1

case "$command" in

ue)  echo "Launching ue: nr-ue -c ue.yaml"
    if [[ ! -z "${GNB_HOSTNAME}" ]] ; then
        export GNB_ADDR="$(host -4 $GNB_HOSTNAME |awk '/has.*address/{print $NF; exit}')"
    fi
    envsubst < /etc/ueransim/ue.yaml > ue.yaml
    sh -c "chmod +x pcap.sh && ./pcap.sh $PCAP_NAME & sleep 10 &&nr-ue -c ue.yaml"
    ;;

gnb)  echo "Launching gnb: nr-gnb -c gnb.yaml UE_HOSTNAME: "${UE_HOSTNAME}"AMF_HOSTNAME:"${AMF_HOSTNAME}
    if [[ ! -z "${UE_HOSTNAME}" ]] ; then
    	echo "Host for gnb is :"$(host -4 $GNB_HOSTNAME)
        export GNB_ADDR="$(host -4 $GNB_HOSTNAME |awk '/has.*address/{print $NF; exit}')"
    fi
    if [[ ! -z "${AMF_HOSTNAME}" ]] ; then
    	echo "Host for amf is :"$(host -4 $AMF_HOSTNAME)
        #export AMF_ADDR="10.100.200.11"
        export AMF_ADDR="$(host -4 $AMF_HOSTNAME |awk '/has.*address/{print $NF; exit}')"
    fi

    envsubst < /etc/ueransim/gnb.yaml > gnb.yaml
    sh -c "chmod +x pcap.sh && ./pcap.sh $PCAP_NAME & sleep 10 && nr-gnb -c gnb.yaml"
    ;;
gnbz)  echo "Launching gnb: nr-gnb -c gnb.yaml UE_HOSTNAME: "${UE_HOSTNAME}"AMF_HOSTNAME:"${AMF_HOSTNAME}
    export PCAP_NAME="gnb3"
    export AMF_HOSTNAME="amf"
    export GNB_HOSTNAME="gnb3"
    export MCC="'208'"
    export MNC="'93'"
    export SST="0x01"
    export SD="0x010203"
    export NCI="'0x0000000122'"
    if [[ ! -z "${UE_HOSTNAME}" ]] ; then
    	echo "Host for gnb is :$GNB_HOSTNAME"
        export GNB_ADDR="10.100.200.22"
    fi
    if [[ ! -z "${AMF_HOSTNAME}" ]] ; then
    	echo "Host for amf is :$AMF_ADDR"
        #export AMF_ADDR="$(host -4 $AMF_HOSTNAME |awk '/has.*address/{print $NF; exit}')"
    fi

    envsubst < /etc/ueransim/gnb.yaml > gnb.yaml
    sh -c "chmod +x pcap.sh && ./pcap.sh $PCAP_NAME & sleep 10 && nr-gnb -c gnb.yaml"
    ;;
*) echo "unknown component $1 is not a component (gnb or ue). Running $@ as command"
   $@
   ;;
esac
