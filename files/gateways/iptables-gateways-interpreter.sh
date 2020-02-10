#!/bin/bash

sudo "$@"

if [ "$1"  == "iptables-restore" ]; then
	echo "# use iptables-restore --noflush" > ~/iptables-gateways
	echo "*nat" >> ~/iptables-gateways
	echo ":PREROUTING -" >> ~/iptables-gateways
	sudo iptables -t nat -S PREROUTING  | grep -- "-j DNAT" >> ~/iptables-gateways
	echo "COMMIT" >> ~/iptables-gateways
	sudo iptables-save > ~/ipt
fi
