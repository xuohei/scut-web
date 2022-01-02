iptables -t nat -N SCUT_PING
iptables -t nat -A SCUT_PING -j DNAT --to-destination 192.168.2.2
iptables -t nat -A PREROUTING -i eth0 -p icmp -j SCUT_PING
ip6tables -t nat -N SCUT_PING
ip6tables -t nat -A SCUT_PING -j DNAT --to-destination fc00::2
ip6tables -t nat -A PREROUTING -i eth0 -p icmp -j SCUT_PING
