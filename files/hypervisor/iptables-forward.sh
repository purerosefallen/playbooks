#!/bin/bash
sudo iptables -t nat -A PREROUTING -m addrtype --dst-type LOCAL -p tcp -m multiport --dports $1 -j DNAT --to-destination $2
sudo iptables -t nat -A PREROUTING -m addrtype --dst-type LOCAL -p udp -m multiport --dports $1 -j DNAT --to-destination $2
cp ./ipt ./ipt.bak
sudo iptables-save > ./ipt
#netfilter-persistent save 
