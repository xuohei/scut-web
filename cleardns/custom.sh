ip addr flush dev eth0
ip addr add 192.168.2.3/24 brd 192.168.2.255 dev eth0
ip route add default via 192.168.2.2
ip -6 addr add fc00::3/64 dev eth0
echo "nameserver 192.168.2.1" > /etc/resolv.conf
nohup /etc/cleardns/frpc/frpc -c /etc/cleardns/frpc/frpc.ini &
