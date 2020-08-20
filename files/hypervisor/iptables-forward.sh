#!/bin/bash
sudo iptables -t nat -A PREROUTING -m addrtype --dst-type LOCAL -p tcp -m multiport --dports $1 -j DNAT --to-destination $2
sudo iptables -t nat -A PREROUTING -m addrtype --dst-type LOCAL -p udp -m multiport --dports $1 -j DNAT --to-destination $2

cp ./ipt ./ipt.bak
sudo iptables-save > ./ipt

echo "# use iptables-restore --noflush" > ~/iptables-gateways
echo "*nat" >> ~/iptables-gateways
echo ":PREROUTING -" >> ~/iptables-gateways
sudo iptables -t nat -S PREROUTING  | grep -- "-j DNAT" >> ~/iptables-gateways
echo "COMMIT" >> ~/iptables-gateways

#netfilter-persistent save 
