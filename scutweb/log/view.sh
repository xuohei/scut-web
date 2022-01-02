tail -f /etc/scutweb/log/access.log | grep --line-buffered -v "223.5.5.5:53\|119.29.29.29:53\|114.114.114.114:53" | grep --color "[0-2][0-9]:[0-5][0-9]:[0-5][0-9]\|accepted"
