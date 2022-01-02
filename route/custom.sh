iptables -t nat -A PREROUTING -d 192.168.2.4 -p udp --dport 53 -j DNAT --to-destination 192.168.2.3:5353
iptables -t nat -A POSTROUTING -d 192.168.2.3 -p udp --dport 5353 -j SNAT --to 192.168.2.4
iptables -t nat -A PREROUTING -d 192.168.2.4 -p tcp --dport 53 -j DNAT --to-destination 192.168.2.3:5353
iptables -t nat -A POSTROUTING -d 192.168.2.3 -p tcp --dport 5353 -j SNAT --to 192.168.2.4
ip6tables -t nat -A PREROUTING -d fc00::4 -p udp --dport 53 -j DNAT --to-destination [fc00::3]:5353
ip6tables -t nat -A POSTROUTING -d fc00::3 -p udp --dport 5353 -j SNAT --to fc00::4
ip6tables -t nat -A PREROUTING -d fc00::4 -p tcp --dport 53 -j DNAT --to-destination [fc00::3]:5353
ip6tables -t nat -A POSTROUTING -d fc00::3 -p tcp --dport 5353 -j SNAT --to fc00::4
