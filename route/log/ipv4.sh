tail -f /etc/route/log/connection.log | grep --line-buffered -o -E "192.168.2..*" | grep --color "\->"
