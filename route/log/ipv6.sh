tail -f /etc/route/log/connection.log | grep --line-buffered -o -E "\[fc00::.*" | grep --color "\->"
